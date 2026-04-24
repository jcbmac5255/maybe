<p align="center">
  <img src="app/assets/images/logo-color.png" alt="Lumen" width="240">
</p>

<h1 align="center">Lumen</h1>

<p align="center">
  A self-hosted personal finance app for households — track accounts, transactions, bills, and net worth, with an AI assistant on top.
</p>


Lumen is a fork of the [Maybe Finance](https://github.com/maybe-finance/maybe) project, which stopped active development at v0.6.0. This fork picks up from there with new features, ongoing maintenance, and a fresh coat of paint.

> **Not affiliated with Maybe Finance Inc.** — Lumen is an independent fork under the [AGPLv3 license](LICENSE). "Maybe" and the Maybe Finance logo are trademarks of Maybe Finance, Inc. and are not used in this project.

## What's new in Lumen

Since the v0.6.0 upstream release, this fork adds:

- **Bills tracker** with a monthly calendar view and optional per-bill "paid from" account that auto-creates transactions and adjusts balances.
- **Anthropic Claude** as an AI provider alongside OpenAI — use `ANTHROPIC_API_KEY` to run the assistant sidebar on Opus 4.7, Sonnet 4.6, or Haiku 4.5. Default model configurable via `DEFAULT_AI_MODEL`.
- **Invite-code deletion** and **password change** directly from security settings.
- **One-command redeploy** via `bin/deploy`, plus a `bin/backup-maybe-db` script for streaming `pg_dump` backups to any S3-compatible bucket.
- **Mobile polish** — the nav, Bills calendar, and auth pages all scale sensibly on small screens.
- **Local `CHANGELOG.md`** rendered on the in-app Changelog page (no more fetching from the dead upstream repo).
- **Rebranded UI** — Lumen name, logos, favicons, PWA manifest, email "from" name, and AI persona.

See [`CHANGELOG.md`](CHANGELOG.md) for the full per-version history.

## Hosting

Lumen runs the same way the upstream Maybe did: Rails + Postgres + Redis + Sidekiq. It can be self-hosted via Docker or directly on a server.

- Docker Compose setup: [`docs/hosting/docker.md`](docs/hosting/docker.md) (inherited from upstream).
- Bare-metal on Ubuntu: run under `systemd` with a `Procfile` + Nginx Proxy Manager (or any reverse proxy with TLS termination) in front.
- Required env vars: `RAILS_ENV=production`, `SECRET_KEY_BASE`, `POSTGRES_{HOST,USER,PASSWORD,DB}`, `APP_DOMAIN`, SMTP settings, and at least one of `ANTHROPIC_API_KEY` or `OPENAI_ACCESS_TOKEN` if you want the AI sidebar.

## Local development

### Requirements

- Ruby version from [`.ruby-version`](.ruby-version)
- PostgreSQL >= 9.3 (ideally the latest stable release)
- Redis

### Quick start

```sh
git clone https://github.com/jcbmac5255/lumen.git
cd lumen
cp .env.local.example .env.local
bin/setup
bin/dev

# Optional: load demo data
rake demo_data:default
```

Visit http://localhost:3000 — the seed creates a login:

- Email: `user@maybe.local`
- Password: `password`

### Pre-PR checks

```sh
bin/rails test                          # unit + integration tests
bin/rubocop -f github -a                # Ruby linter + auto-correct
bundle exec erb_lint ./app/**/*.erb -a  # ERB linter + auto-correct
bin/brakeman --no-pager                 # security analysis
```

### Deploy (prod)

Once your environment is configured, `bin/deploy` runs migrations, precompiles assets, and restarts the service:

```sh
bin/deploy
```

## License & attribution

Lumen is distributed under the [GNU Affero General Public License v3](LICENSE), inherited from upstream Maybe Finance.

- **Upstream project:** https://github.com/maybe-finance/maybe
- **Upstream final release:** [v0.6.0](https://github.com/maybe-finance/maybe/releases/tag/v0.6.0)

"Maybe" and the Maybe Finance logo are trademarks of Maybe Finance, Inc. They are **not** used in this project. Lumen uses its own name, logo, and visual identity.

AGPLv3 requires that any network-accessible deployment of modified source must make that source available to users. If you fork Lumen and run it publicly, you must in turn publish your changes under the same license.
