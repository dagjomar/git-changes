#!/bin/bash

# Git Diff Helper - Shows you information about changes between two commits
# -------------------------------------------------------------------------
# A developer utility script that helps find and show changes done between
# two commits in the git repo in order to help understand what would potentially
# be put into production, etc.
#
# Example outputs:
# - A list of all commit messages
# - A list of all files touched/changed
#
# Optional inputs:
# - Directory to limit the search to
#
# Set up a git alias to run this script:
#   git config --global alias.changes '!git-changes/bin/git-changes.sh'
#
# Then you can simply run:
#   git changes abcdef fedcba
#   git changes abcdef
#   git changes abcdef fedcba ./frontend
#   git changes HEAD~5
# -------------------------------------------------------------------------

function usage() {
  echo "Git Changes - Inspect changes between commits"
  echo
  echo "Usage:"
  echo "  git changes <from> [to] [directory]"
  echo "  git changes <from...to>"
  echo
  echo "Examples:"
  echo "  git changes abc123 def456        # Changes between two commits"
  echo "  git changes abc123               # Changes from commit to HEAD"
  echo "  git changes HEAD~5               # Last 5 commits"
  echo "  git changes abc123...def456      # Using shorthand range syntax"
  echo "  git changes abc123 def456 ./src  # Filter by directory"
  echo
  echo "Arguments:"
  echo "  from        Starting commit hash, branch name, or HEAD relative reference"
  echo "  to          (Optional) Ending commit hash, defaults to HEAD"
  echo "  directory   (Optional) Directory to limit the search to"
  exit 1
}

# Validate input arguments
if [ "$#" -eq 0 ]; then
    usage
fi

# Assign arguments and handle the "from...to" shorthand
if [[ "$1" == *"..."* ]]; then
    IFS="..." read -r commit1 commit2 <<< "$1"
else
    commit1=$1
    commit2=${2:-HEAD} # Default to HEAD if "to" is not provided
    directory=${3:-}   # Optional directory
fi

# Display header
echo "Changes between hash $commit1 -----> $commit2"

# Show commit messages
echo
echo
echo "List of commits:"
git --no-pager log --oneline "$commit1...$commit2" --pretty=format:'%C(red)%h%C(reset) - %C(green)(%ar)%C(reset) %C(auto)%s - %C(bold blue)%an %C(auto)%d'

# Show changed files
echo
echo
echo
echo "List of files changed:"
if [ -n "$directory" ]; then
    git --no-pager diff --name-only "$commit1...$commit2" "$directory"
else
    git --no-pager diff --name-only "$commit1...$commit2"
fi
echo
