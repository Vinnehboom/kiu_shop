# Pottery shop

A web shop for handmade pottery, with a small public site around it.

## Stack

- Ruby 3.3.6 and Rails 7.1, with Postgres.
- Solidus 4 for the store. The starter frontend is copied into this app,
  so this app owns the storefront code.
- Hosted Stripe Checkout for payment. This app never receives a card
  number.
- RSpec, FactoryBot, and RuboCop.

## Set up a development machine

1. Install Ruby 3.3.6 and Postgres.
2. Run `bundle install`.
3. Run `bin/rails db:prepare`.
4. Run `bin/rails tailwindcss:build`.
5. Run `bin/dev` to start the server.

The storefront is at `/`. The admin panel is at `/admin`.

## Run the checks

```
bundle exec rspec
bundle exec rubocop
```

## How work reaches this repository

A Kanban board in Notion holds the tickets. A scheduled orchestrator
session reads that board, picks the next ready ticket, and opens a pull
request for it. `CLAUDE.md` holds the style rules and the limits on what
that automation can do.

The board, the knowledge base, the decisions log, and the style guide are
addressed in `.claude/kanban-cycle.json`, `.claude/knowledge-base.json`,
and `.claude/coding-style.json`.

## Before the shop opens

The shop cannot take real money until a person completes these actions:

- Confirm the tax and registration approach.
- Confirm that the glazes on functional pieces are food-safe.
- Register with the ICO, or confirm the fee exemption.
- Have a professional read the terms of sale and the privacy policy.
