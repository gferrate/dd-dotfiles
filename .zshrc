# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[[ -d "$ZSH" ]] && source "$ZSH/oh-my-zsh.sh"

# Go
export PATH="$(go env GOPATH)/bin:$PATH"

# Enable autojump if available
[[ -s /usr/share/autojump/autojump.zsh ]] && source /usr/share/autojump/autojump.zsh

# Prepend workspace name to prompt (after oh-my-zsh sets PROMPT with git_prompt_info)
if [[ -n "$WORKSPACE_NAME" ]]; then
  PROMPT="%F{cyan}[$WORKSPACE_NAME]%f $PROMPT"
fi

slugify() {
  echo $1 | iconv -t ascii//TRANSLIT | sed -E 's/[~\^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+\|-+$//g' | sed -E 's/^-+//g' | sed -E 's/-+$//g' | tr A-Z a-z
}

create_pr() {
  USER_NAME="gferrate"
  PR_NAME="$1"
  JIRA_ID="$2"

  if [ -z "${PR_NAME}" ]; then
    echo "PR Comment missing"
    return 1
  fi

  if [ -n "${JIRA_ID}" ]; then
    PR_TITLE="[${JIRA_ID}] ${PR_NAME}"
  else
    PR_TITLE="${PR_NAME}"
  fi

  SLUGGED_PR=$(slugify $PR_NAME)
  BRANCH_NAME="$USER_NAME/$SLUGGED_PR"

  MASTER=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
  if [ -z "${MASTER}" ]; then
    echo "Master branch not found"
    return 1
  fi
  git stash
  git checkout $MASTER
  git checkout -b $BRANCH_NAME
  git stash pop
  git add -A
  git commit -am "$PR_TITLE"
  gh pr create -t "$PR_TITLE"
  PR_URL=$(gh pr view --json url -q .url)
  if [ -z "${PR_URL}" ]; then
    echo "PR URL not found"
    return 1
  fi
  echo $PR_URL
  TO_COPY=":pr: [$PR_TITLE]($PR_URL)"

  if command -v pbcopy >/dev/null 2>&1; then
    echo $TO_COPY | pbcopy
    echo "PR link copied to clipboard with Slack formatting"
  else
    echo "pbcopy not available. PR link: $TO_COPY"
    echo "PR link not copied to clipboard - pbcopy command not found"
  fi
}
