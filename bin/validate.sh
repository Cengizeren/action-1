#!/bin/bash
set -euo pipefail

check_dependencies() {

  echo "INFO: Checking dependencies..."

  if [ -z "${PR_NUMBER+x}" ] || [ -z "${PR_TARGET_BRANCH+x}" ]; then
    echo "ERROR: One of (PR_NUMBER, PR_TARGET_BRANCH) is not set."
    exit 1
  fi

  if ! command -v jq &> /dev/null; then
    echo "ERROR: 'jq' command not found. Please make sure 'jq' is installed."
    exit 1
  fi

  if ! command -v gh &> /dev/null; then
    echo "ERROR: 'gh' command not found. Please make sure 'gh' is installed."
    exit 1
  fi

  echo "INFO: All dependencies are installed."
}

check_commit_count() {
  local commits="$1"
  local commit_count=$(echo "$commits" | wc -l)

  if [ "$commit_count" -gt 1 ]; then
    echo "ERROR: PR must have only one well formatted commit message.
    Expected format: <type>(<jiraissue>): <subject>
    Example: feat(XAAS-12345): add new feature
    Allowed types: feat, bugfix, docs, refactor, test, chore
    
    Please squash all commits into one commit using 'git rebase -i main' and force push the changes."
    return 1
  fi

  return 0

}

validate_commit_message() {
  local commit_message="$1"
  local regex="^(feat|bugfix|docs|refactor|test|chore)\(XAAS[P]?-[0-9]+\): .+$"

  if ! [[ "$commit_message" =~ $regex ]]; then
    echo -e "ERROR: Commit message '$commit_message' does not follow the expected format.
    Expected format: <type>(<jiraissue>): <subject>
    Example: feat(XAAS-12345): add new feature
    Allowed types: feat, bugfix, docs, refactor, test, chore"
    return 1
  fi

  echo "INFO: Commit message '$commit_message' is valid."
  return 0
}

validate_branch_name() {
  local branch_name="$1"
  local regex="^(feature|bugfix|chore)\/XAAS[P]?-[0-9]+(-[aA-zZ0-9-]+)?$"

  if ! [[ "$branch_name" =~ $regex ]]; then
    echo -e "ERROR: Branch name '$branch_name' does not follow the expected format.
    Expected format: <type>/XAAS[P]?-<jiraissue>[-short-description]
    Example: feature/XAAS-12345-add-new-feature
    Allowed types: feature, bugfix, chore"
    return 1
  fi

  echo "INFO: Branch name '$branch_name' is valid."
  return 0
}

main() {

  local commits=$(gh pr view $PR_NUMBER --json commits --jq '.commits[].messageHeadline')
  local branch_name=$(gh pr view $PR_NUMBER --json headRefName --jq '.headRefName')

  validate_branch_name "$branch_name"

  if [ "$PR_TARGET_BRANCH" == "main" ]; then
    check_commit_count "$commits"
  fi

  IFS=$'\n'
  for commit in $commits; do
    validate_commit_message "$commit"
  done

}

check_dependencies

main
