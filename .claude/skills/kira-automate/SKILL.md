---
name: kira-automate
description: Plan and carry out a desktop task described in a workflow .md file, using the kira-mcp tools. Asks the user before any critical action.
disable-model-invocation: true
argument-hint: <workflows/task.md>
---

# Desktop automation

Task file: $ARGUMENTS

## How to ask the user
Whenever you need an answer from the user (open questions, plan approval,
critical actions, what to do after a failure), use the AskUserQuestion tool
so they can pick an answer instead of typing it. Give 2-4 short options, put
the recommended one first with "(Recommended)" after its label, and up to 4
questions per call. The user can always choose "Other" and type their own
answer. Only an answer of "Yes" counts as yes.

## 1. Plan (you can only look, not act)
- Read the task file. If Goal or Steps is missing, say what is missing and stop.
- Look at the screen with perceive_screen and find_element. Do not click,
  type or use the clipboard yet.
- Present the plan in this shape:
  - **Preconditions**: what must be true before starting.
  - **Phases**, numbered. Each has a Goal and a Checkpoint (what the screen
    shows when the phase is done). If the phase includes a critical action,
    add a line `Critical: <action>, I will ask you first`.
  - **Do NOT**: copied from the task.
  - **Open questions**: ask instead of guessing. List them in the plan, then
    ask them with AskUserQuestion, one question each with its options.
- Save the plan to `plans/<task file name>-plan.md` (for example
  `plans/export-monthly-report-plan.md`), creating the `plans` folder if
  needed and overwriting an older plan for the same task. Start the file with:
  ```
  # Plan: <Goal from the task file>
  Task file: <path>
  Created: <date and time>
  Status: Awaiting approval
  ```
  then the plan exactly as presented. Writing this file is the one exception
  to "only look", and it is not a critical action. Tell the user the path.
- If the user asks for changes, update the plan, save it to the same file,
  and present it again.
- Wait for the user to approve the plan before doing anything else. Ask with
  AskUserQuestion, options: "Approve plan", "Change the plan" and "Cancel".
  When they approve, set `Status: Approved <date and time>` in the file.

## 2. Critical actions (always ask first)
Any action that does one of these, whether planned or not:
save, save as, overwrite, replace, delete, remove, discard, "don't save",
send, submit, post, publish, share, pay, purchase, order, transfer, confirm,
install, uninstall, reset, sign out, close an app or document,
and the shortcuts Ctrl/Cmd+S, Delete, Ctrl/Cmd+Enter, Alt+F4, Cmd+Q, Ctrl/Cmd+W.
Plus anything listed under "Critical actions" in the task file.

Before a critical action: stop and ask with AskUserQuestion. The question
says exactly what you are about to do (for example "Click **Publish**, which
saves Monthly Report.pdf to the Desktop?"), with the options "Yes" and
"No, stop". If the answer is not "Yes", write the report (section 4) and
stop.

## 3. Run the approved plan
- Work through the phases in order.
- Before every click, call perceive_screen and use the returned cx, cy.
  After every action, look again.
- Extra actions that are not in the plan are fine if they help reach the
  checkpoint and are NOT critical (close a tooltip, dismiss a "what's new"
  popup, scroll, wait for loading). Mention each one as "Extra: ...".
- After each phase print `STEP n: OK`.
- Keep a running record for the report: for each phase, the actions you took
  (planned or extra), each critical action with the user's answer, and the
  checkpoint result.
- If a checkpoint is not reached after 3 extra actions, or you see a login
  prompt, an error, or the wrong app: print `STEP n: FAILED - reason`, write
  the report (section 4), stop, and propose a revised plan. Ask with
  AskUserQuestion, options: "Use the revised plan", "Change it" and "Stop".
- Respect every line under "Do NOT".

## 4. Finish and write the report
When the run ends (all phases OK, a phase FAILED, or the user did not answer
yes to a critical action), save a report to
`reports/<task file name>-<YYYY-MM-DD-HHMM>.md` (for example
`reports/export-monthly-report-2026-10-26-1240.md`), creating the `reports`
folder if needed. Never overwrite an older report. Writing this file is not a
critical action and needs no approval. Use this layout:

```
# Run report: <Goal from the task file>
Task file: <path>
Plan file: <path>
Started: <date and time>
Finished: <date and time>
Result: Success | Failed at phase n - reason | Stopped by user at phase n

## Phases
### Phase n: <name> - OK | FAILED - reason
- Planned: <action>
- Extra: <action>
- Critical: <action>, user answered <answer>
- Checkpoint: <what the screen showed>

## Extra actions
## Critical actions and answers
## Expected result vs actual
<one line per item in the task's "Expected result": met / not met / not checked>
## Problems and notes
```

Write "None" under a heading that has nothing to list. Then summarize the
run in the chat and tell the user the report path.