# My ZSH Config

# Configuration of GIT commiter
```
> cat ~/.gitcredentials
[user]
  name = "thenoseman"
  email = "some@example.com"
```

# Mac OSX Delays:

```bash
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

# MS Teams use virtualcam

```bash
sudo codesign --remove-signature "/Applications/Microsoft Teams.app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper.app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper (GPU).app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper (Renderer).app"
sudo codesign --remove-signature "/Applications/Microsoft Teams.app/Contents/Frameworks/Microsoft Teams Helper (Plugin).app"
```

