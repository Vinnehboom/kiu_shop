# Orchestrator handoff

Generation 2. Predecessor: `session_01D4j1ZASSwAgMgWWxGB1pax` (generation 1).

The predecessor handed over at `cost_usd` $44.38 against a $50 ceiling. It
triaged the open pull requests and then stopped, rather than dispatch a new
ticket, because a ticket dispatch is what took the drafting app's generation
12 from $45.96 to $64.41 in one unattended stretch.

The board, the open pull requests, and the dispatch state are all re-derived
live by `/kanban-cycle`. This note holds only what cannot be.

## Open questions waiting on Vinnie

1. **A-2 merge order.** Pull request 1 adds continuous integration. It works:
   321 examples run, and the runner's Chrome and ChromeDriver match, which the
   pull request had said it could not prove. But the `test` check is red on
   system specs that interfere with each other, so A-2 cannot meet its own
   Done criteria, which require the suite to pass. The recommendation put to
   him: merge A-2 on its own merits, and require the `lint` check on `main`
   but not `test` yet. He has not answered.
2. **Pull request 2** widens the Notion write grant in `CLAUDE.md` to the whole
   pottery shop space, database schema and views included, with delete,
   archive and move still forbidden. He asked for this in session and chose
   that scope. It is a permissions change, so it is outside
   `maintenance_automerge_paths` and waits for his review. **Nothing takes
   effect until it merges**, so until then the narrower grant applies: the
   board, the ticket cards, and the pages named in the two config files.
3. **`.claude/settings.json` is still missing.** This already cost something
   real: a commit-message rewrite on the A-2 branch was refused mid-cycle.
4. **An offer he has not answered:** adding `.claude/worktrees/` to
   `.gitignore`. The stop hook warns about it on every cycle that dispatches
   an agent.
5. **A second offer he has not answered:** opening a ticket for the system
   spec isolation work described below. The predecessor held off because it
   bears on question 1. Raise it again rather than deciding it.

## In-flight nuance that live state reads wrongly

- **Pull request 1's red `test` check is not A-2's fault, and it is not
  yours to fix.** Two runs with two different random seeds gave two different
  failure sets: 9 failures, then 7, with only four in common. That is test
  isolation, not broken pages. Both runs logged
  `duplicate key value violates unique constraint
  "index_spree_order_mutexes_on_order_id"`, `Key (order_id)=(1)`. The
  suspected mechanism: `StoreController` wraps requests in
  `Spree::OrderMutex.with_lock!`, and
  `spec/support/solidus_starter_frontend/database_cleaner.rb` truncates for
  every `js: true` example, which resets the order id to 1. A mutex row that
  outlives its example then collides with the next one's order.
  The diagnosis is in a comment on pull request 1. **Do not skip, tag or
  quarantine a spec, and do not re-run the job looking for a kinder seed.**
- **The commits on pull request 1 carry no `Co-Authored-By: Claude` or
  `Claude-Session` trailer, and that is correct.**
  `ticket-pipeline/references/developer.md` overrides the environment default
  and forbids them on pipeline commits and pull request bodies. A reviewer
  flagged their absence as a finding; the finding is wrong and is withdrawn in
  a comment on the pull request. `main`'s own three commits do carry the
  trailers because the scaffold session is not a pipeline commit. Do not
  "fix" this.
- **A stray local branch may exist in the predecessor's checkout.** It tried
  `a2-trailers` before the classifier refused the rewrite. It was never
  pushed and does not exist on origin.
- **A-2's card reads Review and that is accurate.** The pull request is ready
  for review and waiting on a person, not stalled.

## Pending automation work

These are lessons from this generation that belong in the skill files and were
not written there, because the predecessor was conserving its remaining
budget. They live in `Vinnehboom/claude-automation`, so each needs a branch
and a pull request there.

1. **`ticket-pipeline/references/reviewer.md`** — tell the reviewer that
   pipeline commits and pull request bodies deliberately carry no Claude
   co-author or session trailer. This generation's reviewer reported their
   absence as a finding, the orchestrator relayed it to Vinnie as worth
   fixing, and then had to withdraw both. A reviewer that knows the override
   will not spend a round on it.
2. **`kanban-cycle/SKILL.md`, the environment facts** — the classifier blocks
   rewriting an already-pushed commit's **message**, not only its authorship,
   and it blocks it from the orchestrator's own session, not only from a
   dispatched agent. A cherry-pick onto a temporary branch with an amended
   message was refused as `[Git Destructive]`. A plain `git status` in the
   same compound command was refused with it, so a read-only check needs its
   own call afterwards.
3. **`kanban-cycle/SKILL.md`, reading a failed job log** — a small
   `tail_lines` on `get_job_logs` lands on the Postgres service container's
   teardown log, not the RSpec summary. The summary and the failed-example
   list sit roughly 130 to 200 lines from the end. The service log is printed
   at teardown, which is why the tail misses the failure.
