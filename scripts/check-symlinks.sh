#!/bin/bash
set -euo pipefail

# Check for symlinks in PR to prevent security bypasses (mode 120000 = symlink)

[[ "$PR_NUMBER" =~ ^[0-9]+$ ]] || { echo "Error: Invalid PR number"; exit 1; }

# Get base and head commits
PR_INFO=$(gh pr view "$PR_NUMBER" --json baseRefOid,headRefOid)
BASE_SHA=$(echo "$PR_INFO" | jq -r '.baseRefOid')
HEAD_SHA=$(echo "$PR_INFO" | jq -r '.headRefOid')

# Fetch commits
git fetch origin "$BASE_SHA" "$HEAD_SHA" --quiet

# Check for symlinks in changed files (mode 120000)
SYMLINKS=""
while IFS= read -r file; do
	[ -z "$file" ] && continue
	git cat-file -e "$HEAD_SHA:$file" 2>/dev/null || continue
	FILE_MODE=$(git ls-tree "$HEAD_SHA" "$file" | awk '{print $1}')
	[ "$FILE_MODE" = "120000" ] && SYMLINKS="$SYMLINKS$file"$'\n'
done <<< "$(git diff --name-only "$BASE_SHA" "$HEAD_SHA")"

if [ -n "$SYMLINKS" ]; then
	echo "❌ SECURITY: Symlinks detected in PR. Symlinks are blocked to prevent file access bypasses."
	exit 1
fi

echo "✅ No symlinks found"
