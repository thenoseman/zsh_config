# ZSHENV
# Booted on every shell invocation
#

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Link rbenv build if it dowsn't exist
if [[ ! -h ~/.rbenv/plugins/ruby-build ]]; then 
  mkdir ~/.rbenv/plugins
  ln -s ~/zsh/modules/ruby-build ~/.rbenv/plugins/
fi 
