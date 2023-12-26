# My ZSH Config

# Configuration of GIT commiter
```
> cat ~/.gitcredentials
[user]
  name = "thenoseman"
  email = "some@example.com"
```



# Essential settings

```bash
# Show task switcher on every display
defaults write com.apple.dock appswitcher-all-displays -bool true && killall Dock
```



# MS Teams use virtualcam

```bash
sudo codesign --remove-signature "/Applications/Microsoft Teams.app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper.app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper (GPU).app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper (Renderer).app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper (Plugin).app"
```

# Links
Link from sync to `$HOMEBREW_PREFIX/etc/wireguard`

Link from sync to `$HOMEBREW_PREFIX/etc/coredns/Corefile`

Link `amazon-shell-tools.sh` from sync to `zsh_config/home/.zsh/private`

Create and fill `zsh_config/home/.zsh/private/export.sh`



# Tool notes

`zsh_config/home/.zsh/tools` contains diverse tools like:

- `aws-vault-generate-binstubs.sh`: Generates binstubs that wrap tools dependent on a AWS environment/credentials in aws-vault.
- `exit-frenamer`: Renames all images/videos in the directory and creates/sorts them to a nixe directory structure.
- `execute_maximized` executes a command in a maximized iterm2 window
