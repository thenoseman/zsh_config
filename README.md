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

# Change the whitespace settings value for icons in the menubar
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6

# Do not auto-boot when lid is opened (Original value: %03)
# See https://osxdaily.com/2017/01/19/disable-boot-on-open-lid-macbook-pro/
sudo nvram AutoBoot=%00
```



# Todos fresh install
Install `InconsolataDzNerdFont-Regular.otf` from `zsh_config/home/extras/fonts`.

Execute `relink`.

Execute `update_all`

Execute `update-tools-from-github`

Link from sync to `$HOMEBREW_PREFIX/etc/wireguard`

Link from sync to `$HOMEBREW_PREFIX/etc/coredns/Corefile`

Link `amazon-shell-tools.sh` from sync to `zsh_config/home/.zsh/private`

Create and fill `zsh_config/home/.zsh/private/export.sh`

`colima start -c 4 -d 80 -m 8 -t "vz" --vz-rosetta`

Make spotlight index all prefpanes: `for prefpane in /System/Library/PreferencePanes/*.prefPane; do sudo mdimport $prefpane; done`

## Potential errors

If you get 

```bash
(anon):18: failed to load module `aloxaf/fzftab': dlopen(/Users/.../.zsh/modules/fzf-tab/modules/Src/aloxaf/fzftab.bundle, 0x0009):
```

You may need to go to `/Users/.../.zsh/modules/fzf-tab/modules/Src/aloxaf/` and do `ln -s fzftab.so fzftab.bundle`

# Tool notes

`zsh_config/home/.zsh/tools` contains diverse tools like:

- `aws-vault-generate-binstubs.sh`: Generates binstubs that wrap tools dependent on a AWS environment/credentials in aws-vault. Also allows to override the binary that is actually executed with aws-vault.
- `exif-renamer`: Renames all images/videos in the directory and creates/sorts them to a nixe directory structure.
- `execute_maximized` executes a command in a maximized iterm2 window
- `German no dead-keys.keylayout` install this to make backticks work in MS Teams (copy into `~/Library/Keyboard\ Layouts` and reboot, then add in Settings -> Keyboard) 
