# Hide Previous Reviews Action

This composite action minimizes previous PR reviews and comments made by the github-actions bot to keep pull requests clean and focused on the latest feedback.

## Features

- **Minimizes Previous Reviews**: Hides all but the most recent review from github-actions bot
- **Minimizes Claude Comments**: Hides comments that start with "**Claude finished"
- **GraphQL Optimized**: Uses GitHub's GraphQL API for efficient data retrieval
- **Error Handling**: Gracefully handles API failures and edge cases
- **Safe**: Only affects comments/reviews from github-actions bot

## Usage

```yaml
- name: Hide Previous Reviews
  uses: ./hide-previous-reviews
  with:
    pr_number: ${{ github.event.pull_request.number }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `pr_number` | Pull request number | Yes | - |
| `github_token` | GitHub token with PR permissions | No | `${{ github.token }}` |

### Example with Dynamic PR Number

```yaml
- name: Hide Previous Reviews
  uses: ./hide-previous-reviews
  with:
    pr_number: ${{ github.event_name == 'issue_comment' && github.event.issue.number || github.event.pull_request.number }}
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## How It Works

1. **Retrieves Reviews**: Uses GraphQL to get all reviews by github-actions bot
2. **Preserves Latest**: Keeps the most recent review visible
3. **Minimizes Previous**: Marks older reviews as "outdated" to minimize them
4. **Handles Comments**: Finds and minimizes Claude-specific comments
5. **Reports Status**: Provides clear logging of actions taken

## Permissions Required

The GitHub token must have the following permissions:
- `pull-requests: write` - To minimize reviews and comments
- `contents: read` - To read repository information

## Benefits Over Script Approach

- **No Repository Cloning**: Eliminates the need to clone repositories
- **Better Performance**: Faster execution without git operations
- **Cleaner Interface**: Simple input/output model
- **Better Error Handling**: Integrated with GitHub Actions error reporting
- **Reusable**: Can be used by other workflows independently

## Error Handling

The action includes robust error handling:
- Validates PR number format
- Handles API rate limits gracefully
- Continues processing even if individual operations fail
- Provides clear warning messages for failed operations

## GraphQL Queries Used

The action uses optimized GraphQL queries to:
- Fetch reviews with author and metadata information
- Fetch issue comments with filtering capabilities
- Minimize comments and reviews efficiently

This approach is much more efficient than REST API calls for bulk operations.
