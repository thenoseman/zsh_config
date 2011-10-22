# ZSHENV
# Booted on every shell invocation
#

# Boot RVM (Ruby Version manager) here and not in .zshrc
# Reason: https://rvm.beginrescueend.com/integration/vim/
if [[ -s /Users/`whoami`/.rvm/scripts/rvm ]] ; then source /Users/`whoami`/.rvm/scripts/rvm ; fi
