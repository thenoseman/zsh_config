# profiling (execute zprof after shell is initialized)
#zmodload zsh/zprof

# Add paths to zsh function path
fpath=(~/.zsh/completions ~/.zsh/completions/docker ~/.zsh/zfunctions $fpath)

# crazy tab completion
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

# crazy mad shit
setopt auto_resume auto_cd auto_pushd pushd_to_home pushd_silent pushd_minus
setopt pushd_ignore_dups bad_pattern function_argzero inc_append_history
setopt hist_verify hist_no_store hist_no_functions
setopt hist_ignore_dups hist_find_no_dups hist_save_no_dups
setopt nobeep extended_glob prompt_subst interactive_comments
setopt list_types list_packed print_eight_bit nohup notify
setopt print_exit_value
setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt histignorespace
setopt histignoredups

unsetopt SHARE_HISTORY # share history between sessions ???
unsetopt bgnice nomatch
unsetopt correct_all

HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.history

# eliminate duplicates from these lists
typeset -U hosts path cdpath fpath fignore manpath mailpath classpath

if [ -f "$HOME/.ssh/known_hosts" ]; then
    sshhosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
fi
if [ -f "/etc/hosts" ]; then
    : ${(A)etchosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}}
fi
hosts=($hosts $etchosts $sshhosts)

# completion engine additions
# keep cvs and *~ files out
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS' '(|*/)*\~'
zstyle ':completion:*:cd:*' ignored-patterns '(|*/)CVS'

# kill command completion
zstyle ':completion:*:kill:*:processes' command "ps x"
zstyle ':completion:*:hosts' hosts $hosts
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
zstyle ':completion:*:complete:bundle' use-cache on
zstyle ':completion:*:complete:bundle' rehash false
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' rehash yes

# Disable ^S, useless and annoying
stty stop undef

# Init ZSH help system
unalias run-help &>/dev/null
autoload run-help
HELPDIR=/usr/local/share/zsh/helpfile

# Init async.zsh
source ~/.zsh/modules/pure_prompt/async.zsh
async_init

# gnome-keyring
if [ "${DESKTOP_SESSION}" = "i3" ]; then
  export $(gnome-keyring-daemon --start --components=pkcs11,ssh,secrets)
fi

# Load direnv
eval "$(/usr/local/bin/direnv hook zsh)"

# Includes
for f in ~/.zsh/config/*; do source $f; done
for f in ~/.zsh/private/*; do source $f; done
