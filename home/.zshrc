# profiling (execute zprof after shell is initialized)
# zmodload zsh/zprof

# Add paths to zsh function path
fpath=(/opt/homebrew/share/zsh/site-functions ~/.zsh/zfunctions $fpath)

# crazy tab completion
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# crazy mad shit
setopt APPEND_HISTORY
setopt COMPLETE_IN_WORD
setopt EXTENDED_HISTORY # add timestamps to history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt IGNORE_EOF
setopt INC_APPEND_HISTORY
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP
setopt PROMPT_SUBST
setopt auto_resume auto_cd auto_pushd pushd_to_home pushd_silent pushd_minus
setopt hist_ignore_dups hist_find_no_dups hist_save_no_dups
setopt hist_verify hist_no_store hist_no_functions
setopt histignoredups
setopt histignorespace
setopt list_types list_packed print_eight_bit nohup notify
setopt no_beep extended_glob prompt_subst interactive_comments
setopt print_exit_value
setopt pushd_ignore_dups bad_pattern function_argzero inc_append_history

unsetopt SHARE_HISTORY # share history between sessions ???
unsetopt bgnice nomatch
unsetopt correct_all

export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE=~/.history

# eliminate duplicates from these lists
typeset -U hosts path cdpath fpath fignore manpath mailpath classpath

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Compile all hostsfiles to include them in autocomplete
if [ -f "$HOME/.ssh/known_hosts" ]; then
    sshhosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
fi
if [ -f "/etc/hosts" ]; then
    : ${(A)etchosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}}
fi
hosts=($hosts $etchosts $sshhosts)
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
zstyle ':completion:*' rehash yes

# case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Disable ^S, useless and annoying
stty stop undef

# set homebrew prefix (needs to be sourced!)
source ~/.zsh/config/homebrew

# Init ZSH help system
unalias run-help &>/dev/null
autoload run-help
HELPDIR=$HOMEBREW_PREFIX/share/zsh/helpfile

# Init async.zsh
source ~/.zsh/modules/pure_prompt/async.zsh
async_init

# Load mise (https://mise.jdx.dev/)
eval "$($HOMEBREW_PREFIX/bin/mise activate zsh)"

# https://github.com/gsamokovarov/jump
eval "$($HOMEBREW_PREFIX/bin/jump shell zsh)"

# https://github.com/ajeetdsouza/zoxide
# eval "$($HOMEBREW_PREFIX/bin/zoxide init --no-cmd --hook pwd zsh)"

# Color settings
# vim: set ft=sh:
ccred=$(echo -e "\033[0;31m")
ccgreen=$(echo -e "\033[0;32m")
ccyellow=$(echo -e "\033[0;33m")
ccend=$(echo -e "\033[0m")

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

# CTRL-R - Paste the selected command from history into the command line
# Original: bindkey '^R' history-incremental-search-backward
fzf-history-widget() {
  local selected 
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  # "fc" for history viewing, cut for stripping linenumbers
  selected=( $(fc -rl 1 | cut -c 8- | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf) )
  local ret=$?
  if [ -n "$selected" ]; then
    LBUFFER=$selected
  fi
  zle reset-prompt
  return $ret
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

bindkey -s '^D' "logout\n"

# Linux (see key sequnce using <ctrl-v>anykeycombo

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

# Includes
for f in ~/.zsh/config/*; do source $f; done
for f in ~/.zsh/private/*; do source $f; done

# zprof
