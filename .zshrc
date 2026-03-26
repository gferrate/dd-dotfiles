# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[[ -d "$ZSH" ]] && source "$ZSH/oh-my-zsh.sh"

# Editor
export EDITOR=vim
export VISUAL=vim

# Go
export PATH="$(go env GOPATH)/bin:$PATH"

# Enable autojump if available
[[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh

# Prepend workspace name to prompt (after oh-my-zsh sets PROMPT with git_prompt_info)
if [[ -n "$WORKSPACE_NAME" ]]; then
  PROMPT="%F{cyan}[$WORKSPACE_NAME]%f $PROMPT"
fi

# Aliases
alias cc="claude --dangerously-skip-permissions"

slugify() {
  echo $1 | iconv -t ascii//TRANSLIT | sed -E 's/[~\^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+\|-+$//g' | sed -E 's/^-+//g' | sed -E 's/-+$//g' | tr A-Z a-z
}

create_pr() {
  local USER_NAME="gferrate"
  local PR_NAME="$1"
  local JIRA_ID="$2"
  local ORIGINAL_BRANCH

  if [ -z "${PR_NAME}" ]; then
    echo "Usage: create_pr \"PR title\" [JIRA-ID]"
    return 1
  fi

  if [ -n "${JIRA_ID}" ]; then
    local PR_TITLE="[${JIRA_ID}] ${PR_NAME}"
  else
    local PR_TITLE="${PR_NAME}"
  fi

  local SLUGGED_PR=$(slugify "$PR_NAME")
  local BRANCH_NAME="$USER_NAME/$SLUGGED_PR"

  ORIGINAL_BRANCH=$(git branch --show-current)
  local MASTER=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
  if [ -z "${MASTER}" ]; then
    echo "Error: could not determine default branch"
    return 1
  fi

  # Check for uncommitted changes and stash them
  local STASHED=0
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git stash
    STASHED=1
  fi

  # Switch to default branch
  if ! git checkout "$MASTER"; then
    echo "Error: could not checkout $MASTER"
    [ $STASHED -eq 1 ] && git stash pop
    return 1
  fi

  # Create or switch to the feature branch
  if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "Branch '$BRANCH_NAME' already exists, switching to it"
    if ! git checkout "$BRANCH_NAME"; then
      echo "Error: could not checkout existing branch $BRANCH_NAME"
      git checkout "$ORIGINAL_BRANCH"
      [ $STASHED -eq 1 ] && git stash pop
      return 1
    fi
  else
    if ! git checkout -b "$BRANCH_NAME"; then
      echo "Error: could not create branch $BRANCH_NAME"
      git checkout "$ORIGINAL_BRANCH"
      [ $STASHED -eq 1 ] && git stash pop
      return 1
    fi
  fi

  # Restore stashed changes
  if [ $STASHED -eq 1 ]; then
    if ! git stash pop; then
      echo "Error: could not apply stashed changes (conflict?)"
      return 1
    fi
  fi

  git add -A
  git commit -am "$PR_TITLE" || { echo "Error: nothing to commit"; return 1; }

  if ! gh pr create -t "$PR_TITLE"; then
    echo "Error: could not create PR"
    return 1
  fi

  local PR_URL=$(gh pr view --json url -q .url)
  if [ -z "${PR_URL}" ]; then
    echo "Error: PR created but could not get URL"
    return 1
  fi
  echo "$PR_URL"
  local TO_COPY=":pr: [$PR_TITLE]($PR_URL)"

  if command -v pbcopy >/dev/null 2>&1; then
    echo "$TO_COPY" | pbcopy
    echo "PR link copied to clipboard with Slack formatting"
  else
    echo "pbcopy not available. PR link: $TO_COPY"
  fi
}
