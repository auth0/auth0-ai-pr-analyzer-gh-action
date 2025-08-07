# AI PR Analyzer Github Action

## Example: How to Use the Claude Code Review Github Action

This example shows how to use the reusable Claude Code Review workflow in your repository.

### Create a workflow

Create a workflow in your repository with:

```yaml
name: Claude Code PR Review

on:
  issue_comment:
    types: [ created ]
  pull_request_review_comment:
    types: [ created ]
  pull_request_review:
    types: [ submitted ]

jobs:
  claude-review:
    uses: auth0/ai-pr-analyzer-gh-action/.github/workflows/claude-code-review.yml@main
    with:
      # Optional: Specify files/directories to ignore during review
      disallowed_tools: |
        Read(*_mock.go)
        Read(*.pb.go)
      # Optional: Provide custom review instructions
      custom_review_instructions: |
        When reviewing code changes, please:
        - Focus on Go best practices and idioms
        - Check for proper error handling patterns
        - Verify context usage in long-running operations
        - Review goroutine and channel usage for race conditions
        - Check for proper resource cleanup (defer statements)
```

### Project Context with CLAUDE.md

For comprehensive project context and review instructions, we recommend creating a `CLAUDE.md` file in your repository root instead of using `custom_review_instructions`. This approach provides better organization and maintainability of your AI assistant context.

### Minimal Configuration

For a minimal setup, you don't need to specify any parameters:

```yaml
jobs:
  claude-review:
    uses: auth0/ai-pr-analyzer-gh-action/.github/workflows/claude-code-review.yml@main
```

## Ignoring Files and Directories

By default, `vendor` and `dist` directories, and `package-lock.json` files are ignored from the review.

You can prevent the reviewer from reading specific files and directories by using the `disallowed_tools` parameter with the `Read()` syntax:

```yaml
jobs:
  claude-review:
    uses: auth0/ai-pr-analyzer-gh-action/.github/workflows/claude-code-review.yml@main
    with:
      disallowed_tools: |
        Read(build)
        Read(__pycache__)
```

You can also use wildcards with the star symbol:

```yaml
jobs:
  claude-review:
    uses: auth0/ai-pr-analyzer-gh-action/.github/workflows/claude-code-review.yml@main
    with:
      disallowed_tools: |
        Read(*_mock.go)
        Read(*.pb.go)
        Read(*.generated.ts)
```

To understand better how to use the `disallowed_tools` parameter, check the [Claude Code docs](https://github.com/anthropics/claude-code-action?tab=readme-ov-file#custom-tools)