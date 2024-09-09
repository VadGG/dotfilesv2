#!/usr/bin/env bash

# Colors
CATPPUCCIN_GREEN='#a6da95'
CATPPUCCIN_MAUVE='#c6a0f6'

# Key bindings
COPY_FILE_PATH='ctrl-y:execute(echo -n {1}:{2} | pbcopy)'
KEYS="$COPY_FILE_PATH"

# Function to set key bindings based on a flag
function set_keys() {
  if [[ $1 == '--exit-on-execution' ]]; then
    KEYS="$KEYS+abort"
    shift # remove the flag from the arguments
  fi
}

# Function to run fzf with custom options
function run_fzf() {
  fzf --ansi \
    --border \
    --color "hl+:$CATPPUCCIN_GREEN:reverse,hl:$CATPPUCCIN_MAUVE:reverse" \
    --delimiter ':' \
    --height '100%' \
    --multi \
    --print-query --exit-0 \
    --preview "$1" \
    --preview-window 'right,+{2}+3/3,~3' \
    --scrollbar '▍' \
    --bind "$KEYS"
}

# Function to process selected matches
function process_matches() {
  local selected_matches=("$@")
  for line in "${selected_matches[@]:1}"; do

    if [[ "$line" == *:* ]]; then
      file=$(echo "$line" | cut -d: -f1)
      line_number=$(echo "$line" | cut -d: -f2)
      echo "$file:$line_number"
    else
      echo "$line"
    fi
  done | tr ' ' '\n' | sort -u
}

function process_matches_abs_filepath() {
  local selected_matches=("$@")
  for line in "${selected_matches[@]:1}"; do
    file=$(echo "$line" | cut -d: -f1)
    line_number=$(echo "$line" | cut -d: -f2)
    echo "$(pwd)/$file"
  done | tr ' ' '\n' | sort -u
}

# Function to run grep and fzf together
function run_grep_fzf() {
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
  run_fzf 'bat {1} --highlight-line {2}'
}
