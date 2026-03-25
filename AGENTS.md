# AGENTS.md

## Project overview

Personal dotfiles for remote development workspaces, owned by gferrate. These files are symlinked into `$HOME` on workspace creation via `install.sh`. The dotfiles can be migrated to an internal dotfiles repo for automatic application.

## File structure

- `.zshrc` — Main shell config. Sources oh-my-zsh (robbyrussell theme, git plugin), autojump, workspace prompt customization, and shell helpers (`slugify`, `create_pr`).
- `install.sh` — Runs during workspace creation. Symlinks all dotfiles (files starting with `.`) from `$HOME/dotfiles` to `$HOME`, then installs neovim, gh, and autojump via apt.

## How dotfiles are applied

1. The workspaces system copies this repo to `$HOME/dotfiles` on the workspace.
2. If `install.sh` exists and is executable, it runs instead of the default symlinking behavior.
3. `install.sh` finds all files matching `$HOME/dotfiles/.*` and symlinks them to `$HOME`.
4. `.zshrc` replaces the default workspace `.zshrc`, so it must source oh-my-zsh itself.

## Key behaviors

- The zsh prompt prepends `[WORKSPACE_NAME]` in cyan when `$WORKSPACE_NAME` is set (workspace only, no-op locally).
- `create_pr "PR title" "JIRA-123"` creates a branch, commits, opens a PR, and copies a Slack-formatted link.
- Autojump (`j`) is sourced from `/usr/share/autojump/autojump.zsh` (installed via apt on workspaces).

## Active workspaces

Workspaces are created in `eu-west-3` with `--shell zsh`. Naming convention: `gferrate-<name>-<num>`.

## Security — public repo

This is a public repository. Never commit:
- Secrets, tokens, API keys, or credentials
- Internal company repo names, URLs, or infrastructure details
- Workspace names, hostnames, or IP addresses
- Internal tooling specifics (paths, env vars, service names) that are not already public

When in doubt, keep it generic. Use placeholders like `<internal-repo>` instead of real names.

## Guidelines for editing

- `.zshrc` must source oh-my-zsh before customizing `$PROMPT`, otherwise git branch info is lost.
- Guard workspace-only features with `[[ -n "$WORKSPACE_NAME" ]]`.
- Guard tool sourcing with existence checks (e.g., `[[ -d "$ZSH" ]]`, `[[ -s ... ]]`) so the config doesn't break on machines without those tools.
- `install.sh` must remain executable (`chmod u+x`). Use `set -euo pipefail`.
- Do not add secrets, tokens, or credentials to this repo.
