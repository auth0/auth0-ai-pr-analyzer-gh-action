# Prompt Templates

Default prompt template for Claude Code PR reviews.

## Files

- `prompt.md.tmpl` - Default review prompt template with placeholders

## Placeholders

Templates use `envsubst` for variable substitution:

- `$CUSTOM_REVIEW_INSTRUCTIONS` - User-provided custom review instructions (from `custom_review_instructions` input)

## Usage

Prompt resolution priority:
1. `prompt_file` input - Custom prompt file path
2. `prompt` input - Inline prompt text
3. Default template (this directory)
