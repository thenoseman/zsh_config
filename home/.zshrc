# profiling (execute `ZSH_PROFILE=1 zsh` and run zprof after shell init)
[[ -n ${ZSH_PROFILE:-} ]] && zmodload zsh/zprof

# Add paths to zsh function path
fpath=(/opt/homebrew/share/zsh/site-functions ~/.zsh/zfunctions $fpath)

autoload -Uz compinit
# -C skips the security check (ownership/perms on fpath entries) for fast startup.
# Run `compinit` (without -C) manually after installing new completions to rebuild the dump.
_zcompdump=${ZSH_COMPDUMP:-${HOME}/.zsh/cache/.zcompdump-${ZSH_VERSION}}
compinit -C -d $_zcompdump
# Keep the compiled dump up to date in the background
if [[ $_zcompdump -nt ${_zcompdump}.zwc ]]; then
  zcompile $_zcompdump &!
fi
unset _zcompdump

# History
setopt EXTENDED_HISTORY       # save timestamps in history file
setopt INC_APPEND_HISTORY     # append to history file after each command (not at exit)
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate when a duplicate is added
setopt HIST_IGNORE_SPACE      # don't save commands starting with a space
setopt HIST_REDUCE_BLANKS     # trim superfluous blanks
setopt HIST_VERIFY            # show history expansion before executing
setopt HIST_FIND_NO_DUPS      # don't show duplicates in reverse history search
setopt HIST_SAVE_NO_DUPS      # don't write duplicates to the history file
setopt HIST_NO_STORE          # don't record history/fc commands
setopt HIST_NO_FUNCTIONS      # don't store function definitions in history

# Completion
setopt COMPLETE_IN_WORD       # complete from both ends of a word
setopt LIST_TYPES             # show file type markers in completion lists
setopt LIST_PACKED            # use smaller completion lists where possible
setopt NO_LIST_BEEP           # no beep on ambiguous completions

# Directory navigation
setopt AUTO_CD                # type a directory name to cd into it
setopt AUTO_PUSHD             # push old dir onto stack on every cd
setopt PUSHD_TO_HOME          # pushd with no args goes to $HOME
setopt PUSHD_SILENT           # suppress output from pushd/popd
setopt PUSHD_MINUS            # swap + and - in pushd references
setopt PUSHD_IGNORE_DUPS      # don't push duplicate directories

# Prompt
setopt PROMPT_SUBST           # enable parameter/command expansion in prompts

# Jobs
setopt NO_BG_NICE             # don't lower priority of background jobs
setopt NO_HUP                 # don't send HUP to jobs when shell exits
setopt NOTIFY                 # report job status immediately, not at next prompt

# Shell behaviour
setopt IGNORE_EOF             # don't exit on Ctrl-D
setopt LOCAL_OPTIONS          # allow functions to have local options
setopt LOCAL_TRAPS            # allow functions to have local traps
setopt INTERACTIVE_COMMENTS   # allow comments in interactive shell
setopt PRINT_EIGHT_BIT        # print 8-bit characters in completion lists as-is
setopt PRINT_EXIT_VALUE       # print exit value when non-zero
setopt EXTENDED_GLOB          # extended globbing (^, #, ~, etc.)
setopt BAD_PATTERN            # error on malformed glob patterns
setopt FUNCTION_ARGZERO       # set $0 to the function/script name
setopt AUTO_RESUME            # resume a stopped job when its name is typed
setopt NO_BEEP                # never beep

unsetopt SHARE_HISTORY        # don't share history between concurrent sessions
unsetopt NOMATCH              # pass through unmatched globs instead of erroring
unsetopt CORRECT_ALL          # don't try to autocorrect all arguments

export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE=~/.history

# eliminate duplicates from these lists
typeset -U hosts path cdpath fpath fignore manpath mailpath classpath

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Hosts completion: parse known_hosts + /etc/hosts, cache by mtime
_hosts_cache="${HOME}/.zsh/cache/completion_hosts.zsh"
_hosts_regen=0
[[ ! -f $_hosts_cache ]] && _hosts_regen=1
[[ -f ~/.ssh/known_hosts && ~/.ssh/known_hosts -nt $_hosts_cache ]] && _hosts_regen=1
[[ /etc/hosts -nt $_hosts_cache ]] && _hosts_regen=1

if (( _hosts_regen )); then
  typeset -a _sshhosts=() _etchosts=()
  if [[ -f ~/.ssh/known_hosts ]]; then
    _sshhosts=(${${${${(f)"$(<~/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
  fi
  if [[ -f /etc/hosts ]]; then
    _etchosts=($(awk '/^[^#]/ && NF>1 {for(i=2;i<=NF;i++) print $i}' /etc/hosts))
  fi
  print -r -- "hosts+=( ${(q)_sshhosts[@]} ${(q)_etchosts[@]} )" >| $_hosts_cache
  unset _sshhosts _etchosts
fi
source $_hosts_cache
unset _hosts_cache _hosts_regen
zstyle ':completion:*:hosts' hosts $hosts

# completion engine additions
# keep *~ files out
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)*\~'

# kill command completion
zstyle ':completion:*:kill:*:processes' command "ps x"
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
# Complete cd.. (http://stackoverflow.com/questions/564648/zsh-tab-completion-for-cd)
zstyle ':completion:*' special-dirs true

# Cache completion results
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
#zstyle ':completion:*' rehash yes

# case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Disable XON/XOFF flow control (^S/^Q) in ZLE
unsetopt FLOW_CONTROL

# set homebrew prefix (needs to be sourced!)
export HOMEBREW_PREFIX="/opt/homebrew"
export ARCH="arm64"
export HOMEBREW_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_ASK=1

# Init ZSH help system
unalias run-help &>/dev/null
autoload run-help
HELPDIR=$HOMEBREW_PREFIX/share/zsh/helpfile

# Init async.zsh
#source ~/.zsh/modules/pure_prompt/async.zsh
#async_init

# Load mise (https://mise.jdx.dev/)
_mise_bin="$HOMEBREW_PREFIX/bin/mise"
_mise_cache="${HOME}/.zsh/cache/mise_activate.zsh"
if [[ ! -f $_mise_cache || $_mise_cache -ot $_mise_bin ]]; then
  $_mise_bin activate zsh >| $_mise_cache
fi
source $_mise_cache
unset _mise_bin _mise_cache

# https://github.com/gsamokovarov/jump
_jump_bin="$HOMEBREW_PREFIX/bin/jump"
_jump_cache="${HOME}/.zsh/cache/jump_init.zsh"
if [[ ! -f $_jump_cache || $_jump_cache -ot $_jump_bin ]]; then
  $_jump_bin shell zsh >| $_jump_cache
fi
source $_jump_cache
unset _jump_bin _jump_cache

# https://github.com/ajeetdsouza/zoxide
# eval "$($HOMEBREW_PREFIX/bin/zoxide init --no-cmd --hook pwd zsh)"

# Color settings
# vim: set ft=sh:
ccred=$'\033[0;31m'
ccgreen=$'\033[0;32m'
ccyellow=$'\033[0;33m'
ccend=$'\033[0m'

#
# Keybindings
#

# emacs command editing mode
# https://sgeb.io/posts/2014/04/zsh-zle-custom-widgets/#what-are-keymaps?
bindkey -e

# Make delete work properly in all cases
bindkey "^[[3~" delete-char

# Mac specific keyboard mappings
bindkey '^[[H' beginning-of-line
bindkey '^[[1;5D' beginning-of-line # Magic keyboard large
bindkey '^[[F' end-of-line
bindkey '^[[1;5C' end-of-line # Magic keyboard large
bindkey '^[[5~' up-history
bindkey '^[[6~' down-history

# CTRL-R - fzf history search (body in ~/.zsh/zfunctions/fzf-history-widget)
# Original: bindkey '^R' history-incremental-search-backward
autoload -Uz fzf-history-widget
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

bindkey -s '^D' "logout\n"

# Linux (see key seqeunce using <ctrl-v>anykeycombo)

# ALT-<left>
bindkey "^[[1;3D" backward-word

# ALT-<right>
bindkey "^[[1;3C" forward-word

# strg+alt+7 = "/"
bindkey -s "^_" "/"

# brackets mac like
bindkey -s "^[[5" "["
bindkey -s "^[[6" "]"
bindkey -s "^[[7" "{"
bindkey -s "^[[8" "}"

# alt-n : ~
bindkey -s "^[n" "~"

ulimit -n 8192

# Pre-set hostname to avoid a hostname fork inside iterm2_print_state_data
iterm2_hostname=${HOST:-localhost}

# Includes
for f in ~/.zsh/config/*; do
  [[ $f == *.zwc ]] && continue
  [[ $f == *iterm2* && "$TERM_PROGRAM" != "iTerm.app" ]] && continue
  source $f
done
for f in ~/.zsh/private/*; do source $f; done

[[ -n ${ZSH_PROFILE:-} ]] && zprof
