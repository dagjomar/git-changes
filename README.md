# Git Changes

## A lightweight command-line tool for inspecting Git commit changes

<img src="./docs/git-changes.jpeg" alt="Git Changes Illustration" width="500"/>

<br />

## Overview

Git Changes is a simple, focused command-line utility that helps developers understand changes between Git commits. Whether you're preparing for a deployment, reviewing code changes, or debugging production issues, Git Changes provides a clear, formatted overview of what changed and who made those changes.

## Features

- **Commit History Overview:** See all commits between two points with author and timestamp.

- **Changed Files List:** Quickly identify which files were modified.

- **Directory Filtering:** Focus on changes in specific parts of your codebase.

- **Flexible Reference Support:** Use commit hashes, branch names, or relative references.

## Installation

1. **Clone the Repository:**

```bash
git clone https://github.com/yourusername/git-changes.git
cd git-changes
```

2. **Make the Script Executable:**

```bash
chmod +x bin/git-changes.sh
```

3. **Set Up Git Alias:**
   To simplify usage, set up a Git alias to run the script with git changes:

```bash
git config --global alias.changes '!bash /path/to/git-changes/bin/git-changes.sh'
```

Replace /path/to/git-changes/bin/git-changes.sh with the absolute path to git-changes.sh on your system. This alias allows you to execute the script using git changes.

## Usage

After setting up the alias, you can use the following formats:

- **Compare Using Commit Range:**

```bash
git changes abc123...def456
```

Shows changes between two specific commits.

- **Compare Single Commit to HEAD:**

```bash
git changes abc123
```

Shows changes from the specified commit to the current HEAD.

- **Compare With Directory Filter:**

```bash
git changes abc123 def456 ./src
```

Shows changes only within the specified directory.

## Example Output

```bash
Changes between hash abc123 -----> def456

List of commits:
abc123 - (2 days ago) Add user authentication - Jane Doe
bcd234 - (2 days ago) Fix login validation - John Smith
cde345 - (3 days ago) Update dependencies - Jane Doe

List of files changed:
src/auth/login.js
src/components/LoginForm.jsx
package.json
```

## TODOs

- Add support for showing file diff statistics
- Implement filtering by file type
- Add colorized diff output option
- Create better documentation with real-world use cases

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to enhance Git Changes.

## License

This project is licensed under custom terms - see the [LICENSE](LICENSE) file for details.
