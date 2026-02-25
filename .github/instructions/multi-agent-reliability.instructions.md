---
applyTo: "**/*.{md,agent.md}"
---

# Multi-Agent Workflow Reliability Standards

These rules apply to all agent coordination, sub-agent delegation, and cross-agent handoffs in this workspace. They ensure reliable, deterministic multi-agent behavior by treating agents as distributed system components, not chat interfaces.

Based on: [Multi-agent workflows often fail. Here's how to engineer ones that don't.](https://github.blog/ai-and-ml/generative-ai/multi-agent-workflows-often-fail-heres-how-to-engineer-ones-that-dont/)

---

## 1. Structured Outputs at Every Boundary

When an agent produces results for another agent or for a report, the output MUST follow a defined structure. Never pass unstructured prose between agents.

**Finding format** - every accessibility finding MUST include:
- **Rule ID** (e.g., `WCAG-1.1.1`, `DOCX-ALT-001`, `color-contrast`)
- **Severity** (`critical` | `serious` | `moderate` | `minor`)
- **Location** (file path + line number, or element selector)
- **Description** (one sentence: what is wrong)
- **Remediation** (one sentence: how to fix it)
- **Confidence** (`high` | `medium` | `low`)

**Score format** - every scored output MUST include:
- **Score** (0-100 integer)
- **Grade** (`A` | `B` | `C` | `D` | `F`)
- **Issue counts** by severity (critical/serious/moderate/minor)
- **Pass/fail verdict** (boolean)

**Action result format** - every state-changing action MUST report:
- **Action taken** (what was done)
- **Target** (what was acted on)
- **Result** (`success` | `failure` | `skipped`)
- **Reason** (why, if failure or skipped)

---

## 2. Constrained Action Sets

Every agent MUST operate within an explicitly defined set of allowed actions. If an action is not in the agent's allowed set, it MUST refuse and explain why.

**Read-only agents** (scanners, analyzers, reporters) may:
- Read files, fetch data, run non-destructive commands
- Produce findings, scores, and reports
- Recommend actions for other agents to take

**Read-only agents may NOT:**
- Edit files, create PRs, post comments, or make any state change
- Delegate state-changing work to sub-agents without user confirmation

**State-changing agents** (fixers, admin agents) may:
- Perform their defined set of mutations (listed in each agent's instructions)
- ONLY after explicit user confirmation for each destructive action

**Escalation rule:** If an agent encounters a task outside its action set, it MUST:
1. State what it cannot do and why
2. Name the correct agent for the task
3. Offer to hand off (not silently delegate)

---

## 3. Validate Every Agent Boundary

At every handoff point between agents, validate that the data contract is met before proceeding.

**Before delegating to a sub-agent:**
- Confirm all required inputs are available (file paths, URLs, config, scope)
- If inputs are missing, resolve them (check workspace, ask user) before delegating
- Never delegate with partial context hoping the sub-agent will figure it out

**After receiving sub-agent results:**
- Verify the result contains required structured fields (findings, scores, verdicts)
- If the result is incomplete or malformed, retry once with explicit instructions about what was missing
- If the retry also fails, report the partial result with a clear note about what is missing
- Never silently drop missing data or fabricate results to fill gaps

**Handoff checklist (orchestrator agents):**
1. Intent classified? (what does the user want)
2. Scope resolved? (which repos, files, pages)
3. Config loaded? (scan profiles, preferences)
4. Sub-agent inputs complete? (all required fields present)
5. User confirmation obtained? (for any state-changing actions)

---

## 4. Design for Failure First

Agents operate in non-deterministic environments. Plan for failures at every step.

**Tool call failures:**
- If a tool call fails (API error, timeout, file not found), do NOT silently continue
- Report the failure, explain what was attempted, and offer alternatives
- Never retry the same failing call more than twice

**Partial results:**
- If scanning 10 files and 2 fail, report results for the 8 that succeeded
- Clearly list the 2 failures with reasons
- Offer to retry just the failed items

**Missing context:**
- If a required config file is missing, state the default being used
- If a previous audit report is expected but not found, state that no baseline exists
- Never assume context that isn't verified

**Graceful degradation order:**
1. Try the full workflow
2. If a step fails, try a simpler alternative
3. If no alternative exists, report partial results with clear gaps noted
4. Never return an empty result without explanation

---

## 5. Intermediate State and Progress

For multi-step workflows, report progress at each phase boundary. This serves two purposes: user visibility and debugging when something goes wrong.

**Phase announcements** - at the start of each workflow phase:
- State what phase is starting and what it will do
- State how many items are in scope (files, pages, repos)
- State estimated complexity (quick scan vs. deep analysis)

**Phase completion** - at the end of each phase:
- State what was found or accomplished
- State counts (issues found, files scanned, actions taken)
- State what phase comes next

**Workflow summary** - at the end of the full workflow:
- Recap all phases completed
- Aggregate counts across phases
- Present the final deliverable (report, dashboard, fixed files)

---

## 6. Treat Agents as Distributed System Components

**Ordering matters:** Agents that depend on another agent's output MUST run sequentially. Agents with no data dependencies SHOULD run in parallel.

**Idempotency:** Running the same agent twice with the same inputs should produce the same structured output. Agents must not accumulate hidden state across invocations.

**Isolation:** Each agent operates on its own defined scope. Agent A must not modify files that Agent B is simultaneously analyzing. When parallel scanning groups are used, each group operates on distinct concerns (ARIA vs. contrast vs. forms).

**Contract versioning:** When agent instructions change, the structured output format MUST remain backward-compatible. New fields can be added; existing fields must not be removed or renamed without updating all consumers.

---

## 7. Revert-First Policy

When a user reports that an agent's change broke working functionality, the agent (or orchestrator) MUST follow this sequence:

1. **Offer to revert immediately.** Restoring a working state is the top priority. Do not attempt to "fix forward."
2. **Ask about intended behavior.** Understand what the code was supposed to do before proposing any new change.
3. **Re-implement only after understanding intent.** Choose the right technical approach for the user's actual UX goals.
4. **Verify multi-file impact.** Before changing any structural attribute (ARIA roles, IDs, classes), search all workspace files for references and present the full scope of required changes.

This policy applies to all state-changing agents. Orchestrators must relay revert offers from fixer agents without delay.
