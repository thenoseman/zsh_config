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
defaults write com.apple.dock appswitcher-all-displays -bool true

# Change the whitespace settings value for icons in the menubar
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6

# Tahoe: Disable icons in menu entries
defaults write -g NSMenuEnableActionImages -bool NO

# Disable floating sidebars
defaults write -g NSSplitViewItemSidebarDefaultsToFloatingAppearance -bool false

# Smaller window corners (Sequoia ≈10, Tahoe ≈26)
defaults write -g NSConvolutionOverride1 -float 10

# Sidebar corners like in macos 15 
defaults write -g NSSplitViewItemGlassMinimumCornerRadius -float 10

# Optional: less transparency (will make the menubar ugly grey!)
# defaults write com.apple.universalaccess reduceTransparency -bool true

# Reduced motion
defaults write com.apple.universalaccess reduceMotion -bool true

# Disable edge drag tiling
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
```



# Todos fresh install
Install `InconsolataGoNerdFont-Regular.otf` from `zsh_config/home/extras/fonts`.
(Original: https://raph.levien.com/type/myfonts/inconsolata/)

Execute `relink`.

Execute `update_all`

Link from sync to `$HOMEBREW_PREFIX/etc/wireguard` (deprecated)

Link from sync to `$HOMEBREW_PREFIX/etc/coredns/Corefile` (deprecated)

Link `amazon-shell-tools.sh` from sync to `zsh_config/home/.zsh/private`

Link `export.sh` from sync to `zsh_config/home/.zsh/private`

`colima start -c 4 -d 80 -m 8 -t "vz" --vz-rosetta`

Make spotlight index all prefpanes: `spotlight_index_all`

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
