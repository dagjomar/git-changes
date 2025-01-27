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
#   git changes pick
# -------------------------------------------------------------------------

function usage() {
  echo "Git Changes - Inspect changes between commits"
  echo
  echo "Usage:"
  echo "  git changes <from> [to] [directory]"
  echo "  git changes <from...to>"
  echo "  git changes pick              # Interactive commit selection"
  echo
  echo "Examples:"
  echo "  git changes abc123 def456        # Changes between two commits"
  echo "  git changes abc123               # Changes from commit to HEAD"
  echo "  git changes HEAD~5               # Last 5 commits"
  echo "  git changes abc123...def456      # Using shorthand range syntax"
  echo "  git changes abc123 def456 ./src  # Filter by directory"
  echo "  git changes pick                 # Select commit interactively"
  echo
  echo "Arguments:"
  echo "  from        Starting commit hash, branch name, or HEAD relative reference"
  echo "  to          (Optional) Ending commit hash, defaults to HEAD"
  echo "  directory   (Optional) Directory to limit the search to"
  exit 1
}

function check_dependencies() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: This feature requires 'fzf' to be installed."
    echo
    echo "To install fzf:"
    echo "  Homebrew (macOS): brew install fzf"
    echo "  Ubuntu/Debian:   sudo apt-get install fzf"
    echo "  Other:          Visit https://github.com/junegunn/fzf#installation"
    exit 1
  fi
}

function pick_commit() {
  check_dependencies

  # Use git log to generate the list and fzf to select
  local selected_commit
  selected_commit=$(git log --reverse --color=always --format="%C(red)%h%C(reset) - %C(green)(%ar)%C(reset) %C(auto)%s - %C(bold blue)%an %C(auto)%d" | \
    fzf --ansi \
        --no-mouse \
        --preview 'git show --color=always {1}' \
        --preview-window=right:60% \
        --bind 'ctrl-p:toggle-preview' \
        --header 'Press CTRL-P to toggle commit preview' | \
    cut -d' ' -f1)

  if [ -n "$selected_commit" ]; then
    # Re-run the script with the selected commit
    exec "$0" "$selected_commit"
  else
    echo "No commit selected. Exiting."
    exit 0
  fi
}

function show_changes() {
  local commit1=$1
  local commit2=${2:-HEAD}
  local directory=${3:-}

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
}

# Main script logic
if [ "$#" -eq 0 ]; then
    usage
fi

# Handle subcommands
case "$1" in
  "pick")
    pick_commit
    ;;
  *)
    # Handle the original functionality
    if [[ "$1" == *"..."* ]]; then
        IFS="..." read -r commit1 commit2 <<< "$1"
        show_changes "$commit1" "$commit2"
    else
        show_changes "$1" "${2:-HEAD}" "${3:-}"
    fi
    ;;
esac
