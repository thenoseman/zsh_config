# .bashrc — Bash 5 config mirroring the zsh_config setup
# Sources the same exports/aliases/path configs as .zshrc where compatible.

# Return early if not interactive
[[ $- != *i* ]] && return

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
export HOMEBREW_PREFIX="/opt/homebrew"
export ARCH="arm64"
export HOMEBREW_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_ASK=1

# ---------------------------------------------------------------------------
# Shared config files (exports, path, aliases, functions)
# Stub out zsh-only builtins so sourcing the shared files doesn't error.
# ---------------------------------------------------------------------------

# alias -s (suffix aliases) — silently ignore in bash
alias() {
    local first="$1"
    if [[ $first == -s* ]]; then
        return 0   # skip suffix aliases
    fi
    builtin alias "$@"
}

# autoload — silently ignore in bash (functions are already defined inline)
autoload() { return 0; }

for _f in \
    ~/.zsh/config/exports \
    ~/.zsh/config/path \
    ~/.zsh/config/aliases \
    ~/.zsh/config/functions; do
    [[ -f $_f ]] && source "$_f"
done
unset _f

# Remove the stubs — restore builtins
unset -f alias autoload

# Bash doesn't use zsh suffix aliases; skip silently.
# Override SHELL to bash (exports sets it to zsh)
export SHELL=bash

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
export HISTFILE=~/.history
export HISTSIZE=5000
export HISTFILESIZE=5000
# Equivalent of HIST_IGNORE_ALL_DUPS + HIST_IGNORE_SPACE
export HISTCONTROL=ignoreboth:erasedups
# Don't record history/fc commands themselves
export HISTIGNORE="history:fc *"
# Save timestamps (bash format: ": <epoch>:0;<cmd>")
export HISTTIMEFORMAT="%s "
shopt -s histappend          # INC_APPEND_HISTORY equivalent
shopt -s cmdhist             # Save multi-line commands as one entry
# history -a is called from _pure_prompt_command below

# ---------------------------------------------------------------------------
# Shell behaviour
# ---------------------------------------------------------------------------
shopt -s checkwinsize        # update LINES/COLUMNS after each command
shopt -s autocd 2>/dev/null  # AUTO_CD (bash 4+)
shopt -s globstar 2>/dev/null
set -o ignoreeof             # IGNORE_EOF — don't exit on Ctrl-D

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
ccred=$'\033[0;31m'
ccgreen=$'\033[0;32m'
ccyellow=$'\033[0;33m'
ccend=$'\033[0m'

# ---------------------------------------------------------------------------
# Mise (https://mise.jdx.dev/)
# ---------------------------------------------------------------------------
_mise_bin="$HOMEBREW_PREFIX/bin/mise"
_mise_cache="${HOME}/.zsh/cache/mise_activate.bash"
if [[ ! -f $_mise_cache || $_mise_cache -ot $_mise_bin ]]; then
    "$_mise_bin" activate bash >| "$_mise_cache"
fi
source "$_mise_cache"
unset _mise_bin _mise_cache

# ---------------------------------------------------------------------------
# jump (https://github.com/gsamokovarov/jump)
# ---------------------------------------------------------------------------
_jump_bin="$HOMEBREW_PREFIX/bin/jump"
_jump_cache="${HOME}/.zsh/cache/jump_init.bash"
if [[ ! -f $_jump_cache || $_jump_cache -ot $_jump_bin ]]; then
    "$_jump_bin" shell bash >| "$_jump_cache"
fi
source "$_jump_cache"
unset _jump_bin _jump_cache

# ---------------------------------------------------------------------------
# GPG_TTY
# ---------------------------------------------------------------------------
export GPG_TTY=$(tty)

# ---------------------------------------------------------------------------
# Prompt — Pure-style, matching the zsh prompt visually
#
# Layout (two lines):
#   <green:path> <color242:branch><dirty> <cyan:arrows> <stash>  <exec_time>
#   [virtualenv] ❯  (magenta on success, red on error)
#
# Async git info is collected in a background subshell and written to a
# tmpfile; PROMPT_COMMAND reads it back before rendering PS1.
# ---------------------------------------------------------------------------

# ANSI helpers (wrapped in \[...\] for readline cursor-position accuracy)
_pr_reset='\[\e[0m\]'
_pr_bold='\[\e[1m\]'
_pr_green='\[\e[38;5;2m\]'       # color 002 — path
_pr_grey='\[\e[38;5;242m\]'      # color 242 — branch / user
_pr_red='\[\e[0;31m\]'           # dirty mark / error prompt
_pr_magenta='\[\e[0;35m\]'       # success prompt
_pr_cyan='\[\e[0;36m\]'          # arrows / stash
_pr_yellow='\[\e[0;33m\]'        # exec time

# State variables
_pure_git_branch=""
_pure_git_dirty=""
_pure_git_arrows=""
_pure_git_stash=""
_pure_last_exit=0
_pure_cmd_start=0
_pure_exec_time=""
_pure_async_file=""
_pure_async_pid=0

# ------------------------------------------------------------------
# Async worker: runs git queries in background, writes result to file
# ------------------------------------------------------------------
_pure_async_worker() {
    local outfile="$1"
    local cwd="$2"
    # Must be inside a git repo
    git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null || {
        printf '\x1f\x1f\x1f\x1f' > "$outfile"  # sentinel: no git
        return
    }

    local branch dirty arrows stash
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" describe --tags --exact-match HEAD 2>/dev/null \
             || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

    # dirty check
    if [[ -z $(git -C "$cwd" status --porcelain -unormal 2>/dev/null) ]]; then
        dirty=""
    else
        dirty=$'\e[0;31m'"✘ "$'\e[0m'
    fi

    # arrows (ahead/behind)
    local counts
    counts=$(git -C "$cwd" rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)
    if [[ -n $counts ]]; then
        local left right
        left=${counts%%$'\t'*}
        right=${counts##*$'\t'}
        (( right > 0 )) && arrows+="⇣"
        (( left  > 0 )) && arrows+="⇡"
    fi

    # stash count
    stash=$(git -C "$cwd" rev-list --walk-reflogs --count refs/stash 2>/dev/null)

    # Write FS-separated result
    printf '%s\x1f%s\x1f%s\x1f%s' "$branch" "$dirty" "$arrows" "$stash" > "$outfile"
}

# ------------------------------------------------------------------
# Start async git worker for current directory
# ------------------------------------------------------------------
_pure_async_start() {
    # Kill previous worker if still running
    if (( _pure_async_pid > 0 )); then
        kill "$_pure_async_pid" 2>/dev/null
        _pure_async_pid=0
    fi

    _pure_async_file=$(mktemp "${TMPDIR:-/tmp}/pure_bash_git.XXXXXX")
    # Run worker in background; bash 5 supports process-substitution & disown
    _pure_async_worker "$_pure_async_file" "$PWD" &
    _pure_async_pid=$!
    disown "$_pure_async_pid" 2>/dev/null
}

# ------------------------------------------------------------------
# Poll async result (non-blocking)
# ------------------------------------------------------------------
_pure_async_poll() {
    (( _pure_async_pid == 0 )) && return

    # Check if worker finished
    if ! kill -0 "$_pure_async_pid" 2>/dev/null; then
        _pure_async_pid=0
        if [[ -f $_pure_async_file ]]; then
            local raw
            raw=$(< "$_pure_async_file")
            rm -f "$_pure_async_file"
            _pure_async_file=""

            # Sentinel: no git repo
            if [[ $raw == $'\x1f\x1f\x1f\x1f' || -z $raw ]]; then
                _pure_git_branch=""
                _pure_git_dirty=""
                _pure_git_arrows=""
                _pure_git_stash=""
                return
            fi

            # Parse FS-separated fields
            IFS=$'\x1f' read -r _pure_git_branch _pure_git_dirty _pure_git_arrows _pure_git_stash <<< "$raw"
        fi
    fi
}

# ------------------------------------------------------------------
# Human-readable elapsed time  (matches pure: 1d 2h 3m 4s)
# ------------------------------------------------------------------
_pure_human_time() {
    local secs=$1
    local out=""
    (( secs / 86400 > 0 )) && out+="$(( secs / 86400 ))d "
    (( secs % 86400 / 3600 > 0 )) && out+="$(( secs % 86400 / 3600 ))h "
    (( secs % 3600 / 60 > 0 )) && out+="$(( secs % 3600 / 60 ))m "
    out+="$(( secs % 60 ))s"
    echo "$out"
}

# ------------------------------------------------------------------
# preexec equivalent — record start time
# bash doesn't have preexec natively; use DEBUG trap.
# Guard: only fire once per user command, not for PROMPT_COMMAND internals.
# ------------------------------------------------------------------
_pure_in_prompt=0
_pure_preexec() {
    # Skip if we're inside PROMPT_COMMAND execution
    (( _pure_in_prompt )) && return
    # Only record on the first call per prompt (not for each pipeline stage)
    if (( _pure_cmd_start == 0 )); then
        _pure_cmd_start=$SECONDS
    fi
}
trap '_pure_preexec' DEBUG

# ------------------------------------------------------------------
# PROMPT_COMMAND — runs before each prompt
# ------------------------------------------------------------------
_pure_prompt_command() {
    local last_exit=$?
    _pure_last_exit=$last_exit
    _pure_in_prompt=1   # suppress DEBUG trap during prompt setup

    # Exec time
    _pure_exec_time=""
    if (( _pure_cmd_start > 0 )); then
        local elapsed=$(( SECONDS - _pure_cmd_start ))
        if (( elapsed > ${PURE_CMD_MAX_EXEC_TIME:-5} )); then
            _pure_exec_time=$(_pure_human_time "$elapsed")
        fi
    fi
    _pure_cmd_start=0

    # Poll async git result
    _pure_async_poll

    # Start new async git query for current dir
    _pure_async_start

    # Flush history
    history -a

    # Set terminal title: path
    printf '\e]0;%s\a' "${PWD/$HOME/~}"

    # Build PS1
    _pure_build_ps1
    _pure_in_prompt=0   # re-enable DEBUG trap for user commands
}

# ------------------------------------------------------------------
# Build PS1 (called from PROMPT_COMMAND)
# ------------------------------------------------------------------
_pure_build_ps1() {
    # --- preprompt line ---
    local preprompt=""

    # Username@host (only over SSH or as root, matching pure behaviour)
    if [[ -n $SSH_CONNECTION || $UID -eq 0 ]]; then
        preprompt+="\[\e[38;5;242m\]\\u@\\h\[\e[0m\]"
    fi

    # Path (green, color 002)
    preprompt+="\[\e[38;5;2m\]\w\[\e[0m\]"

    # Git branch + dirty
    if [[ -n $_pure_git_branch ]]; then
        preprompt+="\[\e[38;5;242m\][${_pure_git_branch}]"
        # dirty already contains its own ANSI codes (raw, not readline-wrapped)
        # We must NOT wrap them in \[...\] since they're embedded in the value
        if [[ -n $_pure_git_dirty ]]; then
            preprompt+="\[\e[0m\]${_pure_git_dirty}"
        fi
        preprompt+="\[\e[0m\]"
    fi

    # Arrows
    if [[ -n $_pure_git_arrows ]]; then
        preprompt+="\[\e[0;36m\]${_pure_git_arrows}\[\e[0m\]"
    fi

    # Stash
    if [[ -n $_pure_git_stash && $_pure_git_stash != "0" ]]; then
        preprompt+="\[\e[0;36m\]${PURE_GIT_STASH_SYMBOL:-📚}\[\e[0m\]"
    fi

    # Exec time
    if [[ -n $_pure_exec_time ]]; then
        preprompt+="\[\e[0;33m\]${_pure_exec_time}\[\e[0m\]"
    fi

    # --- prompt line ---
    local prompt_char="${PURE_PROMPT_SYMBOL:-❯}"
    local prompt_color
    if (( _pure_last_exit == 0 )); then
        prompt_color='\[\e[0;35m\]'   # magenta
    else
        prompt_color='\[\e[0;31m\]'   # red
    fi

    # Virtualenv
    local venv_part=""
    if [[ -n $VIRTUAL_ENV ]]; then
        venv_part="\[\e[38;5;242m\]${VIRTUAL_ENV##*/}\[\e[0m\] "
    elif [[ -n $CONDA_DEFAULT_ENV ]]; then
        venv_part="\[\e[38;5;242m\]${CONDA_DEFAULT_ENV}\[\e[0m\] "
    fi

    # Print blank line before prompt (matching pure's initial newline)
    # nf-md-bash icon (U+F0614) prefixes the preprompt line
    local bash_icon="\[\e[38;5;242m\]󱆃\[\e[0m\] "
    PS1="\n${bash_icon}${preprompt}\n${venv_part}${prompt_color}${prompt_char}\[\e[0m\] "
}

# Wire up PROMPT_COMMAND (preserve any existing entries, e.g. mise)
if [[ -z $PROMPT_COMMAND ]]; then
    PROMPT_COMMAND="_pure_prompt_command"
elif [[ $PROMPT_COMMAND != *_pure_prompt_command* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND}; _pure_prompt_command"
fi

# Suppress virtualenv's own prompt modification
export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=no

# ---------------------------------------------------------------------------
# Key bindings (emacs mode, matching .zshrc bindkey -e)
# ---------------------------------------------------------------------------
set -o emacs

# ---------------------------------------------------------------------------
# fzf — ctrl-r history search (identical behaviour to zsh widget)
# ---------------------------------------------------------------------------
# Source fzf's bash integration (provides __fzf_history__ + ctrl-r binding)
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.bash
fi
# Match the zsh widget options: tiebreak=index, ctrl-r toggles sort
export FZF_CTRL_R_OPTS="--tiebreak=index --bind=ctrl-r:toggle-sort"
export FZF_DEFAULT_OPTS="--height 40%"
