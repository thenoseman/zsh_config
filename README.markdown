# My ZSH Config

Important homebrew packages:

brew install autojump brew-cask colordiff ctags direnv exiftool ffmpeg flvstreamer git imagemarick jhead macvim meld mussh node openssl pstree python ebenv readline redis rlwrap ruby-build sqlite tig unrar watch wget youtube-dl zsh

# Configuration of GIT commiter via direnv (.envrc)  
```
export GIT_AUTHOR_NAME="The Noseman"
export GIT_AUTHOR_EMAIL="some.email@example.com"
export GIT_COMMITTER_NAME="The Noseman"
export GIT_COMMITTER_EMAIL="some.email@example.com"
```

# Mac OSX Delays:

```
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g QLPanelAnimationDuration -float 0
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.Dock autohide-delay -float 0
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true
defaults write com.apple.Safari WebKitInitialTimedLayoutDelay 0.25
defaults write NSGlobalDomain KeyRepeat -int 0
```
