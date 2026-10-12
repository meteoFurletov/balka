# Watch list

Owner: <name>. One entry per thing this project runs that must keep working.
Each change adds or updates its entries at the design transition, in its
`spec.md` under Watch, and the entry ships in the same pull request as the thing
it watches. Git is the history: change an entry in place.

<!-- balka:begin -->
## When something breaks

Read this if a check below has failed and called you. You are the responder:
Claude Code, GitHub Copilot or another agent, whichever the entry names. You
are given the entry's name and what the check observed.

1. Read the entry, the facts document named in `.claude/balka.json`, and the
   change directory named in its `Added by` line.
2. Do what the entry's `Responder may` line allows and nothing more:
   - `diagnose`: investigate read-only, then write one draft intent.
   - `propose`: as `diagnose`, then open a pull request that carries only the
     intent.
   - `runbook: <step>`: run that one step first, then as `diagnose`. Run no
     other step, however obvious it looks.
3. Never fix what you diagnosed and never deploy. The fix goes through the loop
   like any other change; the owner decides when.

**Investigate.** Look for what changed when the check started failing: a commit,
an upstream source, the data, the schedule, the environment. Say which. A
failure that starts on one day and stays usually has one cause under it; one
that comes and goes usually has none you can fix in one place. If you cannot
tell, say so: a wrong story costs the owner more than an open question.

**Write the intent.** First look for an open change whose `intent.md` carries
`Watch: <entry name>` and is not yet built. If there is one, add today's
observation under its Problem and write no new intent. Otherwise write
`<artifact-dir>/<NNN>-<slug>/intent.md`, with the next number above the highest
change directory on the default branch. Use the sections the other intents
there use: the header line, Problem, Outcome, Behaviours, Out of scope and Open
questions. Then:

- Put `Watch: <entry name>` under the header line.
- `Author:` is your tool's name. Leave `Owner:` as `<name>` for a person to
  claim. `Status: draft`.
- Problem carries the observation as given, then what you found. Evidence, not
  adjectives.
- Behaviours: where the break shows behaviour the scenarios should have
  covered, say it in plain words. Otherwise write "No scenario changes. The
  existing scenarios must still pass."
- Uncertainty goes under Open questions.
<!-- balka:end -->

## Entries

<One `###` heading per entry, named for what runs. Every line is required; write
"none" where there is nothing.>

### <name of what runs>

- What runs: <the job, service or pipeline, and when it runs>
- Working means: <what is true when it works, in observable terms>
- The check: <the command or script, and what runs it on which schedule>
- Proven red by: <how the loop saw the check fail on a broken input>
- Broken means: <the check result that counts as broken>
- Responder: <Claude Code, GitHub Copilot or another agent>
- Called by: <what starts the responder when the check fails, and with what>
- Responder may: <diagnose | propose | runbook: <one step>>
- Owner: <name>. Added by: `<NNN>-<slug>`.
