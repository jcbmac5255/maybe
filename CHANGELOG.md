# Changelog

All notable changes to this self-hosted fork are listed here. Newest entries go on top.

## 2026-04-23

### Added
- **Anthropic Claude as an AI provider** — the assistant sidebar can now run on Claude (Opus 4.7, Opus 4.6, Sonnet 4.6, or Haiku 4.5) via an `ANTHROPIC_API_KEY`. OpenAI is still supported; whichever key is set drives the model. Streaming chat and tool-calling (so the assistant can look up your accounts, transactions, balances, and income statement) both work with Claude.
- **Bills tracker** — new Bills page with a monthly calendar view showing bills due and their paid status (paid / overdue / upcoming).
- **Paid-from account on bills** — optionally link a bill to a checking or credit card account. Marking the bill paid automatically creates a matching transaction and updates the account balance. Unmarking reverses it.
- **Invite code deletion** — admins can now remove unused invite codes.
- **Password change from Security settings** — no more need to use the password reset flow just to rotate your password.

### Changed
- **Calendar scales better on mobile** — tighter cells, single-letter day headers, and colored status dots instead of truncated name pills on small screens.
- **Changelog page now reads from this file** — no more fetching release notes from the upstream (unmaintained) repo.
- **Feedback page links repointed** to this fork's GitHub and the household Discord.
- **Contact link in user menu** now points to the household Discord instead of the old maintainer's.
- **Version bumped to 0.8.0** for the new AI provider (was 0.7.0, originally 0.6.0 on the upstream fork).
- **Redis error page** setup-guide link repointed to this fork's Docker doc.
- **Removed the upstream i18n disclaimer** from Preferences (pointed at a dead issue).

### Fixed
- Invite-code UI readability in dark mode.
- Modal flash on cached page navigation.

### Infra
- **Production deployment live** at https://maybe.nexgrid.cc via Nginx Proxy Manager → Rails (prod mode).
- **Nightly database backups** streaming `pg_dump` to Hetzner Object Storage with 30-day retention.
- **One-command deploy** via `bin/deploy` (runs migrations, precompiles assets, restarts the service).
