#!/bin/bash

#COMMITS=$(jq -r '.commits[].messageHeadline' pr_commits.json)
COMMITS="feat(XAAS-1111): modified changelog"
echo "Commit messages fetched: $COMMITS"

if [ -z "$COMMITS" ]; then
echo "No commit messages found."
exit 1
fi
JIRA_ID=""
LABEL="other"
echo "Extracting Jira ID..."
for COMMIT in $COMMITS; do
if echo "$COMMIT" | grep -qE '[xX][aA][aA][sS][pP]?-[0-9]+'; then
    JIRA_ID=$(echo "$COMMIT" | grep -oE '[xX][aA][aA][sS][pP]?-[0-9]+')
    echo "Found Jira ID: $JIRA_ID"
    break
fi
done
if [ -z "$JIRA_ID" ]; then
echo "No Jira ID found."
exit 1
fi

echo "$COMMİT"
LABELS=()
# Set the labels based on the commit message
if echo "$COMMIT" | grep -q '^feat'; then
LABELS+=("feature")
echo "Adding label: feature"
fi
if echo "$COMMIT" | grep -q '^bugfix'; then
LABELS+=("bugfix")
echo "Adding label: bugfix"
fi
if echo "$COMMIT" | grep -q '^refactor'; then
LABELS+=("refactor")
echo "Adding label: refactor"
fi
if echo "$COMMIT" | grep -q '^doc'; then
LABELS+=("documentation")
echo "Adding label: documentation"
fi
if echo "$COMMIT" | grep -q '^test'; then
LABELS+=("test")
echo "Adding label: test"
fi
if echo "$COMMIT" | grep -q '^chore'; then
LABELS+=("chore")
echo "Adding label: chore"
fi
# Convert labels array to JSON
LABELS_JSON=$(echo '["'${LABELS[@]}'"]' | sed 's/ /","/g')
