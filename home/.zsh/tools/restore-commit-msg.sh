#!/usr/bin/env bash
set -euo pipefail

#
# Restores a previously backed-up commit message (see backup taken in the
# commit-msg hook) into the current commit message file, but only for a
# genuinely fresh, interactive commit attempt (i.e. no message was supplied
# via -m/-F/-t and it's not a merge/squash/amend).
#
# This is needed because a plain `git commit` always starts from a fresh
# template - Git does NOT reuse .git/COMMIT_EDITMSG from a previous attempt
# that was aborted by a failing commit-msg hook (e.g. a spellchecker).
#
# Usage: restore-commit-msg.sh <commit-msg-file> [commit-source]
#

if [[ $# -lt 1 ]]; then
  echo "Please pass at least one parameter (current msg filename)"
  exit 0
fi

COMMIT_MSG_FILE="$1"
BACKUP_FILE="$(git rev-parse --git-dir)/LEFTHOOK_COMMIT_MSG_BACKUP"

log() {
  if [[ "${LEFTHOOK_DEBUG:-0}" == "1" ]]; then
    printf "%s\n" "$*" >>"$(git rev-parse --show-toplevel)/lefthook.log"
  fi
}

if [[ -f "$BACKUP_FILE" ]]; then
  cp "$BACKUP_FILE" "$COMMIT_MSG_FILE"

  # Single-shot restore: never let a stale backup leak into a later,
  # unrelated commit.
  rm -f "$BACKUP_FILE"
fi

exit 0
