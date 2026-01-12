# Greeting Feature Spec

## Overview
A simple greeting module that demonstrates the Ralph 2.0 handoff workflow.

## Requirements

### P0: Core Greeting
- [ ] Create `src/greet.ts` with a `greet(name: string): string` function
- [ ] Return "Hello, {name}!" format

### P1: Formal Mode  
- [ ] Add optional `formal: boolean` parameter
- [ ] When formal=true, return "Good day, {name}."

### P2: Time-based Greeting
- [ ] Add `greetByTime(name: string, hour: number): string`
- [ ] Morning (5-11): "Good morning, {name}"
- [ ] Afternoon (12-17): "Good afternoon, {name}"
- [ ] Evening (18-21): "Good evening, {name}"
- [ ] Night: "Good night, {name}"
