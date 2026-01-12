#!/usr/bin/env bun
/**
 * Ralph 2.0 Orchestrator
 * 
 * Uses Amp SDK to coordinate planning and build threads.
 * 
 * Usage:
 *   bun run ralph.ts plan     # Create/update implementation plan
 *   bun run ralph.ts build    # Execute tasks from plan
 *   bun run ralph.ts auto     # Plan then build (default)
 */

import { execute, type StreamMessage } from '@sourcegraph/amp-sdk';
import { readFileSync, existsSync } from 'fs';
import { join } from 'path';

const PROJECT_DIR = process.cwd();
const PLAN_FILE = join(PROJECT_DIR, 'IMPLEMENTATION_PLAN.md');

// Colors for output
const colors = {
  green: (s: string) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s: string) => `\x1b[33m${s}\x1b[0m`,
  cyan: (s: string) => `\x1b[36m${s}\x1b[0m`,
  red: (s: string) => `\x1b[31m${s}\x1b[0m`,
};

interface Task {
  id: string;
  description: string;
  scope: string;
  status: string;
  validation: string;
}

function parsePlan(): Task[] {
  if (!existsSync(PLAN_FILE)) return [];
  
  const content = readFileSync(PLAN_FILE, 'utf-8');
  const tasks: Task[] = [];
  
  // Simple parser for our plan format
  const taskRegex = /- \[( |x|~|!)\] (P\d+\.\d+) (.+?)(?=\n  - |\n###|\n##|$)/gs;
  const matches = content.matchAll(taskRegex);
  
  for (const match of matches) {
    const [, status, id, description] = match;
    const taskBlock = match[0];
    
    const scopeMatch = taskBlock.match(/scope:\s*(.+)/);
    const validationMatch = taskBlock.match(/validation:\s*(.+)/);
    
    tasks.push({
      id,
      description: description.trim(),
      scope: scopeMatch?.[1] || '',
      status: status === ' ' ? 'not_started' : status === 'x' ? 'completed' : 'in_progress',
      validation: validationMatch?.[1] || 'npx tsc --noEmit',
    });
  }
  
  return tasks;
}

function getIncompleteTasks(): Task[] {
  return parsePlan().filter(t => t.status === 'not_started');
}

async function runPrompt(prompt: string, parentThreadId?: string): Promise<{ threadId: string; result: string }> {
  const stream = execute({
    prompt,
    options: {
      cwd: PROJECT_DIR,
      dangerouslyAllowAll: true,
      env: parentThreadId ? { AMP_PARENT_THREAD_ID: parentThreadId } : undefined,
    },
  });

  let threadId = '';
  let result = '';

  for await (const msg of stream) {
    if (msg.type === 'system') {
      threadId = msg.session_id;
      console.log(colors.cyan(`Thread: ${threadId}`));
    } else if (msg.type === 'assistant') {
      for (const content of msg.message.content) {
        if (content.type === 'text') {
          process.stdout.write(content.text);
        } else if (content.type === 'tool_use') {
          console.log(colors.yellow(`  [${content.name}]`));
        }
      }
    } else if (msg.type === 'result' && !msg.is_error) {
      result = msg.result;
    }
  }

  return { threadId, result };
}

async function planPhase(): Promise<string> {
  console.log(colors.green('\n=== Planning Phase ===\n'));

  const prompt = `
# Planning Mode

Read @AGENTS.md, @specs/*.md and create/update IMPLEMENTATION_PLAN.md.

For each task include:
- scope: files/directories it touches
- validation: command to verify
- assigned_thread: (leave empty)
- status: not_started

Prioritize as P0 (must have) → P1 (should have) → P2 (nice to have).

When done, summarize the plan.
`;

  const { threadId } = await runPrompt(prompt);
  return threadId;
}

async function buildPhase(coordinatorThreadId: string): Promise<void> {
  console.log(colors.green('\n=== Build Phase ===\n'));

  let iteration = 0;
  const maxIterations = 20;

  while (iteration < maxIterations) {
    const tasks = getIncompleteTasks();
    
    if (tasks.length === 0) {
      console.log(colors.green('\n✓ All tasks complete!'));
      break;
    }

    const task = tasks[0]; // Get highest priority incomplete task
    iteration++;
    
    console.log(colors.green(`\n--- Iteration ${iteration}: ${task.id} ---\n`));

    const prompt = `
# Build Thread: ${task.id}

## Task
${task.description}

## Context
- Scope: ${task.scope}
- Validation: ${task.validation}

## Instructions
1. Implement the task (stay within scope)
2. Run validation: ${task.validation}
3. Update IMPLEMENTATION_PLAN.md - mark ${task.id} as [x] Completed
4. Commit with: feat(${task.scope.split('/').pop()}): ${task.description}

Read @AGENTS.md and @IMPLEMENTATION_PLAN.md first.
`;

    const { result } = await runPrompt(prompt, coordinatorThreadId);
    
    // Check if task was completed
    const updatedTasks = getIncompleteTasks();
    if (updatedTasks.length === tasks.length) {
      console.log(colors.yellow('\nTask may not have completed. Continuing...'));
    }
    
    // Small delay between iterations
    await new Promise(r => setTimeout(r, 1000));
  }
}

async function main() {
  const mode = process.argv[2] || 'auto';
  
  console.log(colors.green(`Ralph 2.0 Orchestrator - ${mode.toUpperCase()} mode`));
  console.log(`Project: ${PROJECT_DIR}\n`);

  let coordinatorThreadId: string | undefined;

  if (mode === 'plan' || mode === 'auto') {
    coordinatorThreadId = await planPhase();
  }

  if (mode === 'build' || mode === 'auto') {
    // If no coordinator thread from planning, create one
    if (!coordinatorThreadId) {
      coordinatorThreadId = `coordinator-${Date.now()}`;
    }
    await buildPhase(coordinatorThreadId);
  }

  console.log(colors.green('\n=== Ralph Complete ===\n'));
}

main().catch(console.error);
