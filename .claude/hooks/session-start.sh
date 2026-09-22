#!/bin/bash
# Prepares the test environment (Postgres, gems, assets, test schema) so
# `bundle exec rspec` and `bundle exec rubocop` work without manual setup.
# Every step is best-effort: a failure here must not block the session from
# starting, it must only leave the manual-setup friction in place.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR" || exit 0

# rbenv installs gem executables under the Ruby prefix, which is not on PATH
# in this image. Without this, `rails` and `rspec` are not found at all.
RBENV_BIN="$(rbenv prefix 2>/dev/null)/bin"
if [ -d "$RBENV_BIN" ]; then
  export PATH="$RBENV_BIN:$PATH"
fi

if [ -n "${POTTERY_SHOP_TEST_KEY:-}" ] && [ ! -f config/credentials/test.key ]; then
  mkdir -p config/credentials
  printf '%s' "$POTTERY_SHOP_TEST_KEY" > config/credentials/test.key
  chmod 600 config/credentials/test.key
fi

if [ -n "${POTTERY_SHOP_GIT_SIGNING_KEY:-}" ]; then
  if ! command -v ssh-keygen >/dev/null 2>&1; then
    sudo apt-get update -qq || true
    sudo apt-get install -y -qq openssh-client || true
  fi
  SIGNING_KEY_PATH="$HOME/.ssh/pottery_shop_signing"
  mkdir -p "$HOME/.ssh"
  printf '%s\n' "$POTTERY_SHOP_GIT_SIGNING_KEY" > "$SIGNING_KEY_PATH"
  chmod 600 "$SIGNING_KEY_PATH"
  git config gpg.format ssh
  git config user.signingkey "$SIGNING_KEY_PATH"
  git config commit.gpgsign true
  # This environment's global gitconfig points gpg.ssh.program at a
  # platform-managed signer that ignores a custom user.signingkey without
  # erroring. Override it repo-locally so the key above is actually used.
  git config gpg.ssh.program "$(command -v ssh-keygen)"
fi

export DEBIAN_FRONTEND=noninteractive
# postgresql-common ships a pg_config shim whether or not libpq-dev's headers
# are present, so checking for pg_config can pass while libpq-fe.h is missing.
# That breaks the pg gem's native build silently. Check for the header itself.
if [ ! -f /usr/include/postgresql/libpq-fe.h ] || ! command -v psql >/dev/null 2>&1; then
  sudo apt-get update -qq || true
  sudo apt-get install -y -qq postgresql libpq-dev || true
fi

# Active Storage variants go through image_processing and vips. Without the
# library, every spec that renders a product image raises LoadError, and the
# error names a missing .so rather than a missing package.
if ! ldconfig -p | grep -q libvips; then
  sudo apt-get update -qq || true
  sudo apt-get install -y -qq libvips42 || true
fi

sudo service postgresql start >/dev/null 2>&1 || true

PG_HBA=$(runuser -u postgres -- psql -tAc 'SHOW hba_file;' 2>/dev/null | tr -d '[:space:]')
if [ -n "$PG_HBA" ] && sudo test -f "$PG_HBA"; then
  sudo sed -i -E 's/^(local[[:space:]]+all[[:space:]]+all[[:space:]]+)\S+/\1trust/' "$PG_HBA" || true
  sudo service postgresql restart >/dev/null 2>&1 || true
fi

# database.yml carries no username, so Rails connects as the current OS user.
# That role does not exist in a fresh container.
runuser -u postgres -- psql -v ON_ERROR_STOP=0 -c \
  "DO \$\$ BEGIN CREATE ROLE \"$(whoami)\" WITH LOGIN SUPERUSER; EXCEPTION WHEN duplicate_object THEN NULL; END \$\$;" \
  >/dev/null 2>&1 || true

if command -v bundle >/dev/null 2>&1; then
  bundle install --quiet || true
fi

# `bundle exec` only looks in GEM_HOME/bin, so gem executables installed under
# the rbenv prefix are invisible to it. Symlink them across.
GEM_BIN="$(ruby -e 'puts Gem.dir' 2>/dev/null)/bin"
if [ -d "$RBENV_BIN" ] && [ -n "$GEM_BIN" ]; then
  mkdir -p "$GEM_BIN"
  for f in "$RBENV_BIN"/*; do
    name="$(basename "$f")"
    [ -e "$GEM_BIN/$name" ] || ln -s "$f" "$GEM_BIN/$name"
  done
fi

if command -v bundle >/dev/null 2>&1; then
  RAILS_ENV=test bundle exec rails db:prepare >/dev/null 2>&1 || true
  RAILS_ENV=test bundle exec rails tailwindcss:build >/dev/null 2>&1 || true
fi

# This hook cannot fetch Notion content itself, because Notion access exists
# only inside the agent's own tool calls. Surface the canonical page instead,
# on stdout, so Claude Code injects it into the session's context.
if [ -f .claude/coding-style.json ]; then
  STYLE_GUIDE_URL=$(grep -o '"notion_page_url"[[:space:]]*:[[:space:]]*"[^"]*"' .claude/coding-style.json | head -1 | sed -E 's/.*"([^"]+)"$/\1/')
  if [ -n "$STYLE_GUIDE_URL" ]; then
    cat <<EOF
Before making code changes in this repo, fetch the Coding Style Guide from Notion ($STYLE_GUIDE_URL) via the notion-fetch tool and treat its Style Rules as binding project style guidance alongside repo conventions — it's the shared source of truth the ticket-pipeline skill also reads before implementing tickets. Skip this fetch only if Notion tools are unavailable this session.
EOF
  fi
fi

exit 0
