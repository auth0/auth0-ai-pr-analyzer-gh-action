#!/bin/bash
set -euo pipefail

# Generate a unique filename for the diff output
DIFF_FILE=$(mktemp "${RUNNER_TEMP}/diff-XXXXXXXXXX")
echo "DIFF_FILE=$DIFF_FILE" >> "$GITHUB_OUTPUT"

EXCLUDE_PATHS=(
	':!**/vendor/**'
	':!**/node_modules/**'
	':!**/dist/**'
	':!**/build/**'
	':!**/out/**'
	':!**/target/**'
	':!**/bin/**'
	':!**/coverage/**'
	':!**/package-lock.json'
	':!**/yarn.lock'
	':!**/pnpm-lock.yaml'
	':!**/composer.lock'
	':!**/Pipfile.lock'
	':!**/poetry.lock'
	':!**/go.sum'
	':!**/*.min.js'
	':!**/*.min.css'
	':!**/*.bundle.js'
	':!**/*.bundle.css'
)

if [ -z "$PR_NUMBER" ]; then
	echo "ERROR: Could not determine PR number from GitHub event"
	exit 1
fi
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
	echo "Error: PR number must be numeric"
	exit 1
fi

# Get all necessary info from the PR in one go using JSON output
PR_INFO_JSON=$(gh pr view "$PR_NUMBER" --json state,baseRefOid,headRefOid,mergeCommit)
if [ -z "$PR_INFO_JSON" ]; then
	echo "ERROR: Could not retrieve information for PR '$PR_NUMBER'. Make sure the PR exists and you have access."
	exit 1
fi

# Parse the JSON response
STATE=$(echo "$PR_INFO_JSON" | jq -r '.state')
BASE_SHA=$(echo "$PR_INFO_JSON" | jq -r '.baseRefOid')
HEAD_SHA=$(echo "$PR_INFO_JSON" | jq -r '.headRefOid')
MERGE_SHA=$(echo "$PR_INFO_JSON" | jq -r '.mergeCommit.oid // ""') # Use // "" for a default empty string if null

echo "PR State: $STATE"

# Fetch the specific commits we need. This is more efficient than fetching branches.
echo "Fetching necessary commits from remote..."
# Collect all SHAs we might need to fetch
SHAS_TO_FETCH=()
[ -n "$BASE_SHA" ] && SHAS_TO_FETCH+=("$BASE_SHA")
[ -n "$HEAD_SHA" ] && SHAS_TO_FETCH+=("$HEAD_SHA")
[ -n "$MERGE_SHA" ] && SHAS_TO_FETCH+=("$MERGE_SHA")
git fetch origin "${SHAS_TO_FETCH[@]}" --quiet

echo "Generating diff with exclusions..."

if [ "$STATE" == "MERGED" ]; then
	if [ -n "$MERGE_SHA" ]; then
		# This was a "Merge Commit" or "Squash and Merge"
		NUM_PARENTS=$(git cat-file -p "$MERGE_SHA" | grep -c "^parent")
		if [ "$NUM_PARENTS" -eq 2 ]; then
			echo "Detected a merge commit ($MERGE_SHA). Diffing against its first parent."
			# The first parent is the tip of the base branch at the time of merge.
			git diff "${MERGE_SHA}^1" "$MERGE_SHA" -- "${EXCLUDE_PATHS[@]}" > "$DIFF_FILE"
		else
			echo "Detected a squash commit ($MERGE_SHA). Diffing against its parent."
			git diff "${MERGE_SHA}^" "$MERGE_SHA" -- "${EXCLUDE_PATHS[@]}" > "$DIFF_FILE"
		fi
	else
		# This was a "Rebase and Merge". There is no merge commit.
		# The diff is between the base SHA before the rebase and the head SHA after.
		echo "Detected a rebase and merge. Diffing between base ($BASE_SHA) and head ($HEAD_SHA) SHAs."
		git diff "$BASE_SHA" "$HEAD_SHA" -- "${EXCLUDE_PATHS[@]}" > "$DIFF_FILE"
	fi
elif [ "$STATE" == "OPEN" ]; then
	# For open PRs, we diff the base and head SHAs.
	echo "PR is open. Diffing between base ($BASE_SHA) and head ($HEAD_SHA) SHAs."
	git diff "$BASE_SHA" "$HEAD_SHA" -- "${EXCLUDE_PATHS[@]}" > "$DIFF_FILE"
else
	echo "ERROR: PR is closed and not merged. No diff to show."
	exit 1
fi

# Verify diff file was created and is not empty
if [ ! -f "$DIFF_FILE" ]; then
	echo "ERROR: $DIFF_FILE was not created"
	exit 1
fi

if [ ! -s "$DIFF_FILE" ]; then
	echo "ERROR: $DIFF_FILE is empty - no changes to review"
	exit 1
fi

echo "Diff generation completed successfully"