# Changelog

All notable changes to this self-hosted fork are listed here. Newest entries go on top.

## 2026-04-24

### Added
- **Bills tracker** — new Bills page with a monthly calendar view showing bills due and their paid status (paid / overdue / upcoming).
- **Paid-from account on bills** — optionally link a bill to a checking or credit card account. Marking the bill paid automatically creates a matching transaction and updates the account balance. Unmarking reverses it.

### Changed
- **Calendar scales better on mobile** — tighter cells, single-letter day headers, and colored status dots instead of truncated name pills on small screens.
- **Changelog page now reads from this file** — no more fetching release notes from the upstream (unmaintained) repo.

## 2026-04-23

### Added
- **Invite code deletion** — admins can now remove unused invite codes.
- **Password change from Security settings** — no more need to use the password reset flow just to rotate your password.

### Fixed
- Invite-code UI readability in dark mode.
- Modal flash on cached page navigation.
