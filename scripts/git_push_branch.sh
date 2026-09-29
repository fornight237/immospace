#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/git_push_branch.sh BRANCH_NAME "commit message"
BRANCH="${1:-ci-build-apk}"
MSG="${2:-Prepare CI build APK artifact}"

echo "Adding changes..."
git add -A

echo "Committing with message: $MSG"
git commit -m "$MSG" || echo "No changes to commit or commit failed"

echo "Pushing to origin/$BRANCH"
git push origin "$BRANCH"

echo "Done. If push failed, check remote or create the branch with 'git push -u origin $BRANCH'."