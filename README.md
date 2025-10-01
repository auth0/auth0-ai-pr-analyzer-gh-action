# AI PR Analyzer GitHub Action

A GitHub Actions workflow that provides AI-powered code reviews using Claude via Amazon Bedrock. Automatically analyze pull requests and provide intelligent feedback when triggered by mentioning `@claude` in PR comments or descriptions.

## Key Features

- **AI-Powered Code Reviews**: Leverages Claude AI through Amazon Bedrock for intelligent code analysis
- **Inline Comments**: Provides line-specific feedback directly in GitHub pull requests
- **Customizable Instructions**: Support for custom review instructions tailored to your project
- **File Filtering**: Ability to exclude specific files or directories from review
- **Clean PR Experience**: Automatically hides outdated bot reviews to keep PRs focused
- **OIDC Authentication**: Secure AWS authentication without long-lived credentials
- **Trigger-Based**: Only runs when explicitly requested via `@claude` mentions

## Installation

Add this reusable workflow to your repository by creating a new workflow file (e.g., `.github/workflows/claude-code-review.yml`):

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
```

## Usage

### Basic Usage

Once the workflow is set up, simply mention `@claude` in:
- Pull request descriptions
- PR comments
- Review comments

The AI will analyze the code changes and provide intelligent feedback.

### Advanced Configuration

#### Custom Review Instructions

```yaml
jobs:
  claude-review:
    uses: auth0/ai-pr-analyzer-gh-action/.github/workflows/claude-code-review.yml@main
    with:
      custom_review_instructions: |
        When reviewing code changes, please:
        - Focus on Go best practices and idioms
        - Check for proper error handling patterns
        - Verify context usage in long-running operations
        - Review goroutine and channel usage for race conditions
        - Check for proper resource cleanup (defer statements)
```

#### Project Context with CLAUDE.md

For comprehensive project context and review instructions, we recommend creating a `CLAUDE.md` file in your repository root instead of using `custom_review_instructions`. This approach provides better organization and maintainability of your AI assistant context.

## Examples

### Minimal Configuration

For a basic setup without any custom parameters:

```yaml
jobs:
  claude-review:
    uses: auth0/ai-pr-analyzer-gh-action/.github/workflows/claude-code-review.yml@main
```

#### Ignoring Files and Directories

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

**Allow additional tools:**
```yaml
jobs:
  claude-review:
    uses: atko-cic/ai-pr-analyzer-gh-action/.github/workflows/claude-code-review.yml@main
    with:
      allowed_tools: "Bash(npm:*),Bash(yarn:*)"
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

For more information on using the `disallowed_tools` parameter, check the [Claude Code documentation](https://github.com/anthropics/claude-code-action/blob/main/docs/configuration.md#custom-tools).

## Contributing

We appreciate feedback and contribution to this repo! Before you get started, please read the following:

- [Auth0's general contribution guidelines](https://github.com/auth0/open-source-template/blob/master/GENERAL-CONTRIBUTING.md)
- [Auth0's code of conduct guidelines](https://github.com/auth0/nextjs-auth0/blob/main/CODE-OF-CONDUCT.md)
- [This repo's contribution guide](./CONTRIBUTING.md)

## Contact/Support

### Raise an Issue

To provide feedback or report a bug, please [raise an issue on our issue tracker](https://github.com/auth0/ai-pr-analyzer-github-action/issues).

## What is Auth0?

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_dark_mode.png" width="150">
    <source media="(prefers-color-scheme: light)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
    <img alt="Auth0 Logo" src="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
  </picture>
</p>
<p align="center">
  Auth0 is an easy to implement, adaptable authentication and authorization platform. To learn more checkout <a href="https://auth0.com/why-auth0">Why Auth0?</a>
</p>
<p align="center">
  This project is licensed under the Apache 2.0 license. See the <a href="./LICENSE"> LICENSE</a> file for more info.
</p>