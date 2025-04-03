#!/bin/bash

set -e

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEST_DIR="/tmp/git-changes-test"
TEST_DATA_DIR="$TEST_DIR/.local/share"
GIT_CHANGES="$SCRIPT_DIR/git-changes.sh"

# Setup test environment
setup() {
    echo "Setting up test environment..."
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Initialize git repo
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create test directory structure
    mkdir -p frontend/src backend/src
    
    # Create and commit frontend files
    echo "console.log('frontend 1');" > frontend/src/app.js
    git add frontend/src/app.js
    git commit -m "Add frontend app.js"
    
    # Create and commit backend files
    echo "print('backend 1')" > backend/src/app.py
    git add backend/src/app.py
    git commit -m "Add backend app.py"
    
    # Make changes to frontend
    echo "console.log('frontend 2');" >> frontend/src/app.js
    git add frontend/src/app.js
    git commit -m "Update frontend code"
    
    # Make changes to both
    echo "console.log('frontend 3');" >> frontend/src/app.js
    echo "print('backend 2')" >> backend/src/app.py
    git add frontend/src/app.js backend/src/app.py
    git commit -m "Update code in both directories"
    
    # Store commit hashes for testing
    FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
    LAST_COMMIT=$(git rev-parse HEAD)
}

# Clean up test environment
cleanup() {
    echo "Cleaning up test environment..."
    rm -rf "$TEST_DIR"
}

# Helper function to count commits in output
count_commits() {
    local result="$1"
    local pattern="$2"
    echo "$result" | sed -n '/List of commits:/,/List of files changed:/p' | grep -c "$pattern" || true
}

# Helper function to count files in output
count_files() {
    local result="$1"
    local pattern="$2"
    echo "$result" | sed -n '/List of files changed:/,$p' | grep -c "$pattern" || true
}

# Run tests
run_tests() {
    echo "Running tests..."
    
    # Test 1: Check frontend directory filter
    echo "Test 1: Frontend directory filter"
    result=$("$GIT_CHANGES" "$FIRST_COMMIT" "$LAST_COMMIT" frontend)
    
    # Count commits that modified frontend files
    commit_count=$(count_commits "$result" "frontend\|both directories")
    
    # Count frontend files in the changed files list
    file_count=$(count_files "$result" "frontend/src/app.js")
    
    # Check that no backend files are listed
    backend_files=$(count_files "$result" "backend/src/app.py")
    
    # Should show 3 commits: initial add, update, and both directories update
    if [ "$commit_count" -ne 3 ] || [ "$file_count" -ne 1 ] || [ "$backend_files" -ne 0 ]; then
        echo "❌ Test 1 failed:"
        echo "  Expected: 3 frontend commits (initial + update + both), 1 frontend file, 0 backend files"
        echo "  Got: $commit_count frontend commits, $file_count frontend files, $backend_files backend files"
        echo
        echo "=== Debug: Frontend filter output ==="
        echo "$result"
        echo "=== End debug output ==="
        return 1
    fi
    echo "✅ Test 1 passed"
    
    # Test 2: Check backend directory filter
    echo "Test 2: Backend directory filter"
    result=$("$GIT_CHANGES" "$FIRST_COMMIT" "$LAST_COMMIT" backend)
    
    # Count commits that modified backend files
    commit_count=$(count_commits "$result" "backend\|both directories")
    
    # Count backend files in the changed files list
    file_count=$(count_files "$result" "backend/src/app.py")
    
    # Check that no frontend files are listed
    frontend_files=$(count_files "$result" "frontend/src/app.js")
    
    # Should show 2 commits: initial add and both directories update
    if [ "$commit_count" -ne 2 ] || [ "$file_count" -ne 1 ] || [ "$frontend_files" -ne 0 ]; then
        echo "❌ Test 2 failed:"
        echo "  Expected: 2 backend commits (initial + both), 1 backend file, 0 frontend files"
        echo "  Got: $commit_count backend commits, $file_count backend files, $frontend_files frontend files"
        echo
        echo "=== Debug: Backend filter output ==="
        echo "$result"
        echo "=== End debug output ==="
        return 1
    fi
    echo "✅ Test 2 passed"
    
    # Test 3: Check no filter (should show all changes)
    echo "Test 3: No directory filter"
    result=$("$GIT_CHANGES" "$FIRST_COMMIT" "$LAST_COMMIT")
    
    # Count all commits
    commit_count=$(count_commits "$result" "Add\|Update")
    
    # Count all files
    file_count=$(count_files "$result" "src/app\.")
    
    # Should show all 4 commits and both files
    if [ "$commit_count" -ne 4 ] || [ "$file_count" -ne 2 ]; then
        echo "❌ Test 3 failed:"
        echo "  Expected: 4 commits (2 adds + 1 update + 1 both), 2 files"
        echo "  Got: $commit_count commits, $file_count files"
        echo
        echo "=== Debug: No filter output ==="
        echo "$result"
        echo "=== End debug output ==="
        return 1
    fi
    echo "✅ Test 3 passed"
    
    # Test 4: Check commit that touches multiple directories
    echo "Test 4: Multi-directory commit"
    last_commit=$(git rev-parse HEAD)
    second_last=$(git rev-parse HEAD~1)
    
    # Check frontend filter
    result=$("$GIT_CHANGES" "$second_last" "$last_commit" frontend)
    commit_count=$(count_commits "$result" "both directories")
    file_count=$(count_files "$result" "frontend/src/app.js")
    backend_files=$(count_files "$result" "backend/src/app.py")
    
    if [ "$commit_count" -ne 1 ] || [ "$file_count" -ne 1 ] || [ "$backend_files" -ne 0 ]; then
        echo "❌ Test 4 failed: Frontend filter incorrect"
        echo "  Expected: 1 commit, 1 frontend file, 0 backend files"
        echo "  Got: $commit_count commits, $file_count frontend files, $backend_files backend files"
        echo
        echo "=== Debug: Frontend filter output ==="
        echo "$result"
        echo "=== End debug output ==="
        return 1
    fi
    
    # Check backend filter
    result=$("$GIT_CHANGES" "$second_last" "$last_commit" backend)
    commit_count=$(count_commits "$result" "both directories")
    file_count=$(count_files "$result" "backend/src/app.py")
    frontend_files=$(count_files "$result" "frontend/src/app.js")
    
    if [ "$commit_count" -ne 1 ] || [ "$file_count" -ne 1 ] || [ "$frontend_files" -ne 0 ]; then
        echo "❌ Test 4 failed: Backend filter incorrect"
        echo "  Expected: 1 commit, 1 backend file, 0 frontend files"
        echo "  Got: $commit_count commits, $file_count backend files, $frontend_files frontend files"
        echo
        echo "=== Debug: Backend filter output ==="
        echo "$result"
        echo "=== End debug output ==="
        return 1
    fi
    echo "✅ Test 4 passed"
    
    # Test 5: Check that FROM commit is excluded but TO commit is included
    echo "Test 5: FROM commit exclusion"
    
    # Create a sequence of commits to test with
    echo "console.log('frontend 4');" >> frontend/src/app.js
    git add frontend/src/app.js
    git commit -m "First commit to test FROM exclusion"
    
    first_test_commit=$(git rev-parse HEAD)
    
    echo "console.log('frontend 5');" >> frontend/src/app.js
    git add frontend/src/app.js
    git commit -m "Second commit to test FROM exclusion"
    
    second_test_commit=$(git rev-parse HEAD)
    
    echo "console.log('frontend 6');" >> frontend/src/app.js
    git add frontend/src/app.js
    git commit -m "Third commit to test FROM exclusion"
    
    third_test_commit=$(git rev-parse HEAD)
    
    # Test the range from first to third commit
    result=$("$GIT_CHANGES" "$first_test_commit" "$third_test_commit" frontend)
    
    # Should only show "Second commit" and "Third commit", not "First commit"
    commit_count=$(count_commits "$result" "test FROM exclusion")
    first_commit_present=$(echo "$result" | grep -c "First commit" || true)
    
    if [ "$commit_count" -ne 2 ] || [ "$first_commit_present" -ne 0 ]; then
        echo "❌ Test 5 failed:"
        echo "  Expected: 2 commits (excluding FROM commit), First commit should not be present"
        echo "  Got: $commit_count commits, First commit present: $first_commit_present"
        echo
        echo "=== Debug: FROM exclusion test output ==="
        echo "$result"
        echo "=== End debug output ==="
        return 1
    fi
    echo "✅ Test 5 passed"
    
    echo "All tests passed! 🎉"
    return 0
}

# Main test execution
trap cleanup EXIT
setup
run_tests 
