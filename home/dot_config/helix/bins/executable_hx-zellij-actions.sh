#!/usr/bin/env bash
# zellij-helper.sh
# A script to interact with Zellij floating panes for various commands

set -e

# Parse command arguments
cmd=$1           # Command to execute
cwd=$2           # Current working directory
filename=$3      # File name
line_number=$4   # Line number (optional)

# Resolve paths
basedir=$(dirname "$filename")
basename=$(basename "$filename")
abspath=$filename

# Resolve tilde (~) to HOME directory
[[ "$abspath" =~ ^~(/|$) ]] && abspath="${HOME}${abspath:1}"

# Colors and FZF configuration
CATPPUCCIN_GREEN='#a6da95'
CATPPUCCIN_MAUVE='#c6a0f6'

# Key bindings
COPY_FILE_PATH='ctrl-y:execute(echo -n {1}:{2} | pbcopy)'
KEYS="$COPY_FILE_PATH"

# Create the fzf command string
FZF_COMMAND="fzf --ansi \
    --border \
    --color \"hl+:$CATPPUCCIN_GREEN:reverse,hl:$CATPPUCCIN_MAUVE:reverse\" \
    --delimiter ':' \
    --height '100%' \
    --multi \
    --print-query --exit-0 \
    --scrollbar '▍' \
    --bind \"$KEYS\""

#######################
# Helper Functions
#######################

send_helix_command() {
    local cmd=$1
    cat << EOF
        zellij action toggle-floating-panes
        zellij action write 27
        zellij action write-chars "$cmd"
        zellij action write 13
        zellij action toggle-floating-panes
        zellij action close-pane
EOF
}

run_in_floating_pane() {
    local dir=$1
    local command=$2
    local helix_cmd=${3:-":reload-all"}
    
    zellij run -f -x 10% -y 10% --width 80% --height 80% -- bash -c "
        cd \"$dir\" && $command
        if [[ \$? -eq 0 ]]; then
            $(send_helix_command "$helix_cmd")
        else
            zellij action close-pane
        fi"
}

#######################
# Command Handlers
#######################

handle_git() {
    local subcmd=$1
    local dir=$2
    
    case "$subcmd" in
        "lazygit")
            run_in_floating_pane "$dir" "lazygit" ;;
        "blame")
            zellij run -f -x 10% -y 10% --width 80% --height 80% -- bash -c "
                cd \"$dir\" && git blame \"$filename\" | 
                $FZF_COMMAND --preview 'echo {}' || true
                zellij action close-pane"
            ;;
        *)
            echo "Unknown git command: $subcmd" && exit 1 ;;
    esac
}

handle_serpl() {
    local dir=$1
    run_in_floating_pane "$dir" "serpl"
}

handle_explorer() {
    local dir=$1
    local start_path=$2
    zellij run -f -x 10% -y 10% --width 80% --height 80% -- bash -c '
        cd "$1"
        selected=$(yazi "$2" --chooser-file=/dev/stdout | while read -r file; do printf "%q " "$file"; done)
        if [ -n "$selected" ]; then
            zellij action toggle-floating-panes
            zellij action write 27
            zellij action write-chars ":open $selected"
            zellij action write 13
            zellij action toggle-floating-panes
        fi
        zellij action close-pane
    ' _ "$dir" "$start_path"
}

handle_fzf_open() {
    local dir=$1
    zellij run -f -x 10% -y 10% --width 80% --height 80% -- bash -c "
        cd \"$dir\"
        selected=\$(rg --files --color=always | 
                    $FZF_COMMAND --preview 'bat --style=numbers --color=always {}' | 
                    tail -n +2 | 
                    tr '\n' ' ')
        if [ -n \"\$selected\" ]; then
            zellij action toggle-floating-panes
            zellij action write 27
            zellij action write-chars \":open \$selected\"
            zellij action write 13
            zellij action toggle-floating-panes
        fi
        zellij action close-pane
    "
}

handle_fzf_rename() {
    local dir=$1
    zellij run -f -x 10% -y 10% --width 80% --height 80% -- bash -c "
        cd \"$dir\"
        selected=\$(rg --files --color=always | 
                    $FZF_COMMAND --preview 'bat --style=numbers --color=always {}' |
                    tail -n +2 | 
                    tr '\n' ' ')
        if [ -n \"\$selected\" ]; then
            echo \"\$selected\" | xargs renamer
            zellij action toggle-floating-panes
            zellij action write 27
            zellij action write-chars \":reload-all\"
            zellij action write 13
            zellij action toggle-floating-panes
        fi
        zellij action close-pane
    "
}

#######################
# Main Command Router
#######################

# Extract location modifier from command
location=$(echo "$cmd" | grep -o '\-cwd$' || echo '')
cmd=${cmd%-cwd}
dir=${location:+"$basedir"}
dir=${dir:-"$cwd"}

case "$cmd" in
    "lazygit")      handle_git "lazygit" "$dir" ;;
    "git-blame")    handle_git "blame" "$dir" ;;
    "serpl")        handle_serpl "$dir" ;;
    "explorer")     handle_explorer "$dir" "$filename" ;;
    "fzf-open")     handle_fzf_open "$dir" ;;
    "fzf-rename")   handle_fzf_rename "$dir" ;;
    *)              echo "Unknown command: $cmd" && exit 1 ;;
esac
