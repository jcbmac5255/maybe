# Contributing to Lumen

Thanks for your interest in contributing to Lumen! This is a self-hosted fork of the (no-longer-maintained) [Maybe Finance](https://github.com/maybe-finance/maybe) project, picked up with new features and ongoing maintenance.

## Before you start

- Read through [`CLAUDE.md`](CLAUDE.md) — it documents the project conventions (Rails style, Hotwire-first frontend, testing philosophy, the TailwindCSS design system). Written for AI coding assistants, but works just as well as a primer for humans.
- Check existing [issues](https://github.com/jcbmac5255/lumen/issues) and [PRs](https://github.com/jcbmac5255/lumen/pulls) before starting work on something so we don't duplicate effort.
- When multiple PRs target the same issue, preference goes to whichever one most cleanly solves the problem within the scope that was asked for.

## What to contribute

- **Bug fixes** — always welcome.
- **Small features** — quality-of-life improvements, UI polish, mobile fixes, additional account types or import formats.
- **Documentation** — setup guides, deployment recipes, screenshots in the README.

For larger features, open an issue first to discuss scope before starting implementation.

## Development

### Setup

See the [README](README.md#local-development) for the short version. Requirements:

- Ruby version from [`.ruby-version`](.ruby-version)
- PostgreSQL >= 9.3
- Redis

```sh
git clone https://github.com/jcbmac5255/lumen.git
cd lumen
cp .env.local.example .env.local
bin/setup
bin/dev
```

Dev Containers are also supported — see the `.devcontainer` folder if you prefer that workflow.

### Pre-PR checks

Before opening a PR, run the full check suite:

```sh
bin/rails test                          # unit + integration tests
bin/rubocop -f github -a                # Ruby linter + auto-correct
bundle exec erb_lint ./app/**/*.erb -a  # ERB linter + auto-correct
bin/brakeman --no-pager                 # security analysis
```

### Making a Pull Request

1. Fork the repo
2. Create a feature branch: `git checkout -b my-new-feature`
3. Commit your changes with a clear message
4. Push the branch: `git push origin my-new-feature`
5. Open the PR against `main` and tick **"Allow edits from maintainers"**
6. [Link the PR to an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword) if one exists (`fixes #123`)
7. Confirm all GitHub Checks pass and the branch is up to date with `main` before requesting review

## License & attribution

Lumen is distributed under the [GNU AGPLv3](LICENSE), inherited from upstream Maybe Finance. Any code you contribute will be released under the same license.

"Maybe" and the Maybe Finance logo are trademarks of Maybe Finance, Inc. and are not used in this project. Please respect that if you share screenshots or write about Lumen.
