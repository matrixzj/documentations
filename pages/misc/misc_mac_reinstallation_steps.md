---
title: Mac Reinstallation Steps
tags: [misc]
keywords: mac, reinstallation
last_updated: Mar 9, 2022
summary: "Steps to reinstall a workbox for myself"
sidebar: mydoc_sidebar
permalink: misc_mac_reinstallation_steps.html
folder: Misc
---

# Mac Reinstallation Steps
=====

## Mandantory

### Install Xcode Command Line Tools
[Xode Command Line Tools](https://developer.apple.com/download/more/)

### Install Brew
[Homebrew](https://brew.sh/)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install zsh
[on-my-zsh github repo](https://github.com/robbyrussell/oh-my-zsh)

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### Install tmux
```bash
brew install tmux
```

### Git Config
```bash
git config --global user.name "Matrix Zou"

git config --global user.email matrix.zj@gmail.com
```

### show path in Finder title bar
```bash
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true; killall Finder
```

### Set New Hostname

```bash
sudo scutil --set HostName <new host name>
sudo scutil --set LocalHostName <new host name>
sudo scutil --set ComputerName <new name>
dscacheutil -flushcache
```
reboot to take it in effect

### Install gnu-sed/gawk
```bash
brew install gnu-sed
brew install gawk
```

PATH config
```
$ brew list gawk | grep 'bin/awk'
/usr/local/Cellar/gawk/5.1.0/bin/awk

$ brew list gnu-sed | grep 'bin'
/usr/local/Cellar/gnu-sed/4.8/bin/gsed

$ echo 'export PATH="/usr/local/Cellar/gawk/5.1.0/bi:/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.zshrc
```

### eul MacOS Monitor 
```
brew install --cask eul
```

### Application Install list
* [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
* [iTerm2](https://iterm2.com/downloads.html)
* [ATOM](https://atom.io/)
* [AIDente](https://github.com/davidwernhart/AlDente/releases)
* [coconutBattery](https://www.coconut-flavour.com/coconutbattery/)
* [Rectangle](https://rectangleapp.com/)
* [Input Method - Squirrel 鼠须管](https://matrixzj.github.io/documentations/misc_mac_reinstallation_steps.html#squirrel-%E9%BC%A0%E9%A1%BB%E7%AE%A1)
* [IINA](https://iina.io/)
* [Keka](https://www.keka.io/en/)
* [WeChat](https://www.wechat.com/en/)
* [QQ](https://im.qq.com/macqq/)
* [Discord](https://discord.com/)
* [Logitech Options](https://www.logitech.com/en-us/software/options.html)
* [Office](https://www.office.com/)
* [Microsoft Teams](https://www.microsoft.com/en-ww/microsoft-teams/download-app)
* Kensingtonworks for K75370

## Applicaiton Setup

### iTerm2  
- Enable utf-8 for iTerm2

```bash
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc
echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
```

### Karabiner Complex Modifications  
complex modifications config location
```bash
/Users/jzou/.config/karabiner/assets/complex_modifications
```

### Squirrel 鼠须管  
#### Installation
[Squirrel](https://rime.im/download/)
```bash
brew install --cask squirrel
```

[Install Wubi jidian Input](https://awesomeopensource.com/project/KyleBing/rime-wubi86-jidian)
```bash
cd Downloads
git clone https://github.com/KyleBing/rime-wubi86-jidian.git
cp -aRv rime-wubi86-jidian/* ~/Library/Rime
```

#### Enable Chinese Input in Atom/iterm2
- Find out iTerm2 Bundle Identifier: com.googlecode.iterm2
```
$ cat /Applications/iTerm.app/Contents/Info.plist | grep -i identifier -A 1
    <key>CFBundleIdentifier</key>
    <string>com.googlecode.iterm2</string>
```

- Find out Atom Bundle Identifier: com.github.atom
```
$ cat /Applications/Atom.app/Contents/Info.plist | grep -i identifier -A 1
    <key>CFBundleIdentifier</key>
    <string>com.github.atom</string>
```

- Update RIME config
add folloing block to ~/Library/Rime/squirrel.custom.yaml
```bash
patch:  
  app_options/com.apple.Xcode:   
    ascii_mode: true    
  app_options/com.github.atom: {}   
  app_options/com.googlecode.iterm2: {}    
```

#### Add custom phase
```
echo "胖胖\teueu" >> wubi86_jidian.dict.yaml
```

### Prevent GlobalProtect VPN from auto-starting on the Mac
```
sudo sed -i 's/true/false/g' /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist
sudo sed -i 's/true/false/g' /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist
```


### Atom
- Packages  
  + highlight-selected
  + markdown-folding
  + markdown-toc
  + pretty-json
  + split-diff
  + sync-settings(cbf14a66fee383e153528992cd2cf98e)

- Disable ‘Enter’ for Autocomplete/Snippets  
  Settings -> Packages -> autocomplete-plus -> Settings -> Keymap For Confirming A suggestion, change it from 'tab and enter' to 'tab'


### Mail Signature

## Optional   
### Virt-Manager on Mac
[virt-manager on Mac github repo](https://github.com/jeffreywildman/homebrew-virt-manager)

```bash
brew tap jeffreywildman/homebrew-virt-manager
brew install virt-manager virt-viewer
```

### iStart Menus Activation Key

```bash
Email: 982092332@qq.com
SN: GAWAE-FCWQ3-P8NYB-C7GF7-NEDRT-Q5DTB-MFZG6-6NEQC-CRMUD-8MZ2K-66SRB-SU8EW-EDLZ9-TGH3S-8SGA
```

{% include links.html %}
