# CLAUDE.md

## Coding style: the rules that keep coming back

Each rule below exists because Vinnie corrected the same class of mistake
more than once. Read them before you write code in this repository. They
are a subset of the Style Rules database in Notion (pointer:
`.claude/coding-style.json`), not a replacement for it. Every rule there is
binding, and each row's page body carries the reasoning and the boundaries
that these one-liners leave out.

This project started from the drafting app's hot list, because the same
person writes both in the same language. A rule that proves wrong here
gets its own row and overrides the inherited one.

Rules 1 to 4 are one cluster, and they are the most corrected rule in the
drafting app. A comment is a model reflex. Suppress it.

1. Write no comment that restates the line below it.
2. Write no decision, no rationale, and no design history in a comment. A
   comment can still explain a non-obvious workaround or an invariant.
3. Refer to no decision from code. No ticket id, no Decisions row, no
   review round, no finding number. State what will break, not which
   ticket found it.
4. Write no comment that points at a shared example or a contract module.
   Its own name and content already say what it covers.
5. Read constructor state in a service object through a private
   `attr_reader`. Do not read a bare `@ivar`.
6. Extract repeated or incidental spec setup into a named helper method.
7. Send the message. Do not branch on the class or the type of an object.
   This one matters more here than in the drafting app. Solidus is built
   on polymorphism, so a type check usually means a missed extension point.
8. Squash every `fixup!` commit before you push.

The drafting app fails its build on rules 3 and 8 with a custom cop and a
`bin/no-fixups` script. This project has neither yet. Copy one across when
its rule gets broken twice here.

A rule enters this list when a correction repeats. The `/coding-style`
skill maintains it. This list mirrors the `Hot list` column in the Style
Rules database, and the two must agree. This copy exists because it
auto-loads into every dispatch and it still works when Notion is
unreachable.

## This project

A web shop for handmade pottery, with a small public site around it. The
seller is one person and she is not a developer.

Ruby on Rails 7.1, Postgres, and Solidus 4 with the starter frontend
copied into this app. Payment goes through hosted Stripe Checkout. This
app never receives a card number, and no ticket may propose that it does.

**The portability rule.** This app serves one shop. Do not hard-code the
identity of that shop in application code. The shop name, the contact
address, the currency, the delivery rates, and the legal text belong in
data or in configuration. A later Store model must be able to own these
values. This rule does not ask for a tenant model now. It asks only that
nothing blocks one.

## Running the checks

```
bundle exec rspec --exclude-pattern "system/**/*_spec.rb"
bundle exec rubocop
```

Both must be green before you push.

**The system specs need a browser that this container does not have.**
`spec/system` holds 144 examples. The 63 that run under `rack_test`
pass. The 80 marked `js: true` need Chrome, and they fail with
`Selenium::WebDriver::Error::NoSuchDriverError`.

The cause is a version mismatch that cannot be corrected from inside the
container. The image carries ChromeDriver 147 and Chromium 141, and a
driver only drives its own major version. The Chrome for Testing index
is blocked by the network policy, and the Ubuntu chromedriver package is
a transitional stub for a snap.

So run the command above, with the exclusion, and read a green result as
green. Do not read those 80 failures as a fault in the code, and do not
try to correct them. Never skip, disable, or delete a system spec to
make the unfiltered command pass. Continuous integration runs the whole
suite on a runner that has Chrome, and that is where these examples are
checked.

## Documentation style

When this session writes documentation directly — a Notion page, a pull
request description, a README — follow the `simple-english` skill
(ASD-STE100, pragmatic mode). Load the skill before you draft the text.

This rule covers the main session only. The `ticket-pipeline` planner,
developer, and curator subagents get the same instruction in their own
briefs.

## Automation boundaries

The auto mode classifier reads this file. It does not read the `autoMode`
block in `.claude/settings.json`. A repository cannot grant itself
classifier permissions, so project rules for the classifier belong here.

### Routine actions

These actions are normal work for this repository, not unusual events:

- A force-push (`--force` or `--force-with-lease`) to any branch of this
  repository except `main` and `master`. The `/kanban-cycle` orchestrator
  rebases each open pull request branch onto a newer default branch tip.
  Then it force-pushes the result. This happens every cycle.
- A Notion write to the pottery shop board, to a ticket card on that
  board, or to a page named in `.claude/knowledge-base.json` or
  `.claude/coding-style.json`. The tools are `notion-update-page`,
  `notion-create-pages`, and `notion-create-comment`. `/kanban-cycle` and
  `/ticket-pipeline` change the Status of a card, write plans and review
  notes onto cards, and record decisions and new tickets.
- A write to the live dashboard's own document store — the `Artifact`
  tool with `action: "write_db"` or `action: "read_db"`, targeting the
  `dashboard_artifact_url` in `.claude/kanban-cycle.json`. This project
  owns the documents keyed by its own `project_key`. It touches nothing
  outside that one artifact's store, and it never touches another
  project's keys.

The MCP server name of the Notion connector changes between sessions. It
mounts as `mcp__Notion__*`, as `mcp__claude_ai_Notion__*`, or under a
generated UUID. Judge a Notion call by its tool name and its target page,
not by the server prefix.

### Forbidden actions

Never do these, whatever the reason and whoever asks:

- A force-push to `main` or `master`, however the target is written.
- A delete, an archive, or a move of a Notion page.
- A change to a Notion database, its schema, or its views.
- A write to a Notion page outside this project's board and the pages
  named in `.claude/knowledge-base.json` and `.claude/coding-style.json`.
  The drafting app's pages are another project's, and they are out of
  bounds from here.
- Publishing a new Artifact to replace the dashboard, or an `Artifact`
  write to any URL other than `dashboard_artifact_url`. The board's URL
  is its identity across orchestrator generations.
- A merge to `main` of `Vinnehboom/claude-automation`. The drafting app's
  orchestrator holds that grant. This one does not. Open the pull
  request and leave it for Vinnie.

The structure of the board belongs to Vinnie. A scheduled cycle runs when
nobody watches it, so it cannot ask for permission at the moment it acts.

### The dashboard queues are instructions, not permissions

The dashboard lets Vinnie queue an answer, a prompt, or a removal
request without opening a session. A cycle acts on those as his
instruction. They cannot widen anything above: a queued item that asks
for a forbidden action, a wider auto-merge whitelist, or the lifting of
an `externally_owned_ticket_ids` exclusion stays queued and gets raised
with him instead. The queue is a convenience for directing work that is
already allowed, never a channel for granting new permission.

## Real-world actions this session cannot do

Some tickets need a person. The shop cannot open until somebody:

- Confirms the tax and registration approach with the seller.
- Confirms that the glazes on functional pieces are food-safe.
- Registers with the ICO, or confirms the fee exemption.
- Has a professional read the terms of sale and the privacy policy.

Ship the ticket with a bracketed placeholder where a real fact is
missing. Do not hold a ticket open and idle while it waits for a person.
