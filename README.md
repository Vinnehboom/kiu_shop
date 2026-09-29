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
   To create the first admin, run
   `ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=a-long-secret bin/rails db:seed`.
4. Run `bin/rails tailwindcss:build`.
5. Run `bin/dev` to start the server.

The storefront is at `/`. The admin panel is at `/admin`.

## Deploy

The app runs on Render. The file `render.yaml` is a Blueprint. It
describes one web service and one Postgres database, both on the free
plan, in Frankfurt.

To deploy the first time:

1. In Render, choose New, then Blueprint, and pick this repository.
2. Fill in the variables that Render asks for. They are listed below.
3. Open the web service and start a manual deploy.

Deploys are manual. A push to `main` does not deploy.

These variables are set by hand:

- `SHOP_NAME`: the name of the shop.
- `SHOP_MAIL_FROM`: the sender address for the shop.
- `ADMIN_EMAIL`: the email of the first admin.
- `ADMIN_PASSWORD`: the password of the first admin.

Render sets `DATABASE_URL` and `SECRET_KEY_BASE` itself.

You can add `APP_HOST` by hand, but you do not need it. It is the host
name of the shop. It is `RENDER_EXTERNAL_HOSTNAME` when you leave it
out.

After you sign in to the admin panel for the first time, change the
admin password. Then delete `ADMIN_PASSWORD` and `ADMIN_EMAIL` from the
Render environment. The app does not use them again.

The free plan has no release command. So the container runs
`bin/rails db:prepare db:seed` each time it starts, before the server.
The seeds are safe to run again. The Solidus defaults and the store are
created only when no store exists. The admin is created only when no
admin exists. A later start does only these two checks.

Limits of the free plan:

- The web service sleeps when idle. The first visit after a sleep is slow.
- The free Postgres database expires after about 30 days.
- Uploaded files are lost on each deploy. Active Storage uses the local
  disk.
- The app sends no email yet.

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
