#!/usr/bin/env zsh
#
# Genrates aws-vault wrapper binstubs
#
set -e
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd -P)

for bin in aws packer terraform; do
  cat <<-EOF > $script_dir/$bin
#!/usr/bin/env zsh
# vim: set ft=sh:
set -e

[[ -e "/opt/homebrew/bin" ]] && HOMEBREW_PREFIX="/opt/homebrew" || HOMEBREW_PREFIX="/usr/local"

if [[ -n \$AWS_VAULT ]] || [[ -n \$VIMRUNTIME ]]; then
  exec "\$HOMEBREW_PREFIX/bin/$bin" "\$@"
fi

if [[ -z \$AWS_PROFILE ]]; then
  exec "\$HOMEBREW_PREFIX/bin/$bin" "\$@"
fi

exec aws-vault exec --duration 1h "\$AWS_PROFILE" -- "\$HOMEBREW_PREFIX/bin/$bin" "\$@"
EOF
done
