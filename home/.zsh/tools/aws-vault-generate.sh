for bin in aws packer terraform; do
  cat <<-EOF > $bin
#!/usr/bin/env zsh
# vim: set ft=sh:
set -e

if [[ -n \$AWS_VAULT ]] || [[ -n \$VIMRUNTIME ]]; then
  exec "/opt/homebrew/bin/$bin" "\$@"
fi

if [[ -z \$AWS_PROFILE ]]; then
  exec "/opt/homebrew/bin/$bin" "\$@"
fi

exec aws-vault exec "\$AWS_PROFILE" -- "/opt/homebrew/bin/$bin" "\$@"
EOF
done
