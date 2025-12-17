#!/usr/bin/env bash
#
# create-prompt.sh
#
# Renders Claude prompt for PR reviews based on user inputs.
#
# 1. If 'prompt_file' input is provided, use its contents
# 2. If 'prompt' input is provided, use its contents
# 3. Otherwise use default prompt rendered from templates/
#
# Args:
# $1 - Path to root of repo running the action
# $2 - Path to root of action code repository
# $3 - (optional) Path to file containing prompt_file input
# $4 - (optional) Path to file containing prompt input
# $5 - (optional) Path to file containing custom_review_instructions input
# $6 - (optional) Output file path (default: /tmp/prompt.md)
# $7 - (optional) Path to the diff file

set -euo pipefail

main() {
  local -r repo_root="${1}"
  local -r action_root="${2}"
  local -r input_prompt_file="${3:-}"
  local -r input_prompt="${4:-}"
  local -r input_custom_review_instructions="${5:-}"
  local -r outfile="${6:-/tmp/prompt.md}"
  local -r diff_file="${7:-}"

  # If 'input_prompt_file' is provided, use its contents
  if [ -n "${input_prompt_file}" ]; then
    echo "Using 'prompt_file' ${input_prompt_file}"

    # Ensure file exists
    if [ ! -f "${input_prompt_file}" ]; then
      echo "Error: Got prompt_file '${input_prompt_file}' that does not exist."
      exit 1
    fi

    # Ensure file is within repo workspace
    local resolved_path
    if ! resolved_path=$(readlink -f "${input_prompt_file}" 2>&1); then
      echo "Error: Could not resolve path for '${input_prompt_file}': ${resolved_path}"
      exit 1
    fi
    if [ -z "${resolved_path}" ]; then
      echo "Error: Could not resolve path for '${input_prompt_file}'"
      exit 1
    fi
    if [[ ! "${resolved_path}" == "${repo_root}"* ]]; then
      echo "Error: prompt_file must be within the repo root"
      exit 1
    fi
    cp "${resolved_path}" "${outfile}"

  # If 'prompt' input is provided, use its file contents if not empty
  elif [ -s "${input_prompt}" ]; then
    echo "Using 'prompt' input value provided"
    cp "${input_prompt}" "${outfile}"

  # If no user values provided, use default prompt rendered from template
  else
    echo "No prompt provided; using default"

    if [[ ! "${diff_file}" =~ ^${RUNNER_TEMP}/diff-[a-zA-Z0-9]{10}$ ]]; then
      echo "ERROR: Invalid diff file path: ${diff_file}"
      exit 1
    fi

    local -r prompt_template="${action_root}/templates/prompt.md.tmpl"
    if [ ! -f "${prompt_template}" ]; then
      echo "Error: Prompt template not found at expected path."
      exit 1
    fi

    # Load custom input instructions, if provided
    local custom_review_instructions=""
    if [ -s "${input_custom_review_instructions}" ]; then
      custom_review_instructions=$(<"${input_custom_review_instructions}")
    fi

    if ! command -v envsubst >/dev/null 2>&1; then
      echo "Error: envsubst not found."
      exit 1
    fi

    # Render the prompt template with envsubst
    env -i \
      CUSTOM_REVIEW_INSTRUCTIONS="${custom_review_instructions}" \
      DIFF_FILE="${diff_file}" \
      envsubst '$CUSTOM_REVIEW_INSTRUCTIONS $DIFF_FILE' < "${prompt_template}" > "${outfile}"
  fi
}

main "$@"
