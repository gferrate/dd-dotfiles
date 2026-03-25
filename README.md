# dd-dotfiles

Personal dotfiles for Datadog Workspaces.

## What's included

- `.zshrc` — shell helpers (`slugify`, `create_pr` for quick PR creation with Slack-formatted links)
- `install.sh` — symlinks dotfiles to home directory and installs neovim + gh

## Setup

Migrate to the internal dotfiles repo:

```bash
workspaces dotfiles migrate https://github.com/gferrate/dd-dotfiles
```

Then create a workspace (dotfiles are applied automatically):

```bash
workspaces create gferrate-<num> --region eu-west-3 --repo dogweb --shell zsh
```
