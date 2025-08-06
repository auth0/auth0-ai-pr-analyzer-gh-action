# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a GitHub Actions repository that provides reusable workflows for AI-powered code reviews using Claude via Amazon Bedrock. The main components are:

1. **Claude Code Review Workflow** (`.github/workflows/claude-code-review.yml`) - A reusable workflow that performs AI code reviews
2. **Hide Previous Reviews Action** (`hide-previous-reviews/`) - A composite action that minimizes old bot reviews to keep PRs clean

## Architecture

### Main Workflow (`claude-code-review.yml`)
- Reusable workflow that can be called from other repositories
- Triggered when `@claude` is mentioned in PR bodies, comments, or reviews
- Uses OIDC authentication with AWS Bedrock for Claude AI access
- Submits inline code review comments using GitHub's review system

### Hide Previous Reviews Action (`hide-previous-reviews/`)
- Composite action that uses GitHub's GraphQL API
- Minimizes previous reviews and comments from github-actions bot
- Preserves only the most recent review to reduce clutter
- Uses bash scripts with GraphQL queries for efficient operation

## Key Features

- **AI Code Reviews**: Uses Claude via Bedrock for intelligent code analysis
- **Inline Comments**: Provides line-specific feedback through GitHub's review system
- **Clean PR Experience**: Automatically hides outdated bot reviews
- **Customizable Instructions**: Supports custom review instructions per repository

## Development Commands

This repository contains only YAML configuration files and bash scripts. No build, test, or lint commands are required as it's a pure GitHub Actions repository.

## Configuration

### For consumers of this action:
- Reference the reusable workflow from your target organization/repository
- Optionally provide `custom_review_instructions` for language-specific guidance
- Ensure proper permissions: `contents: write`, `pull-requests: write`, `issues: write`, `id-token: write`

## Usage Pattern

1. User mentions `@claude` in a PR or comment
2. Workflow triggers and authenticates with AWS
3. Claude analyzes the code changes using the diff
4. Review is submitted with inline comments
5. Previous reviews are automatically hidden to keep PR clean

## Security Notes

- Uses pinned action versions with SHA hashes for security
- OIDC authentication eliminates need for long-lived AWS credentials
- Only processes reviews when explicitly triggered by `@claude` mention