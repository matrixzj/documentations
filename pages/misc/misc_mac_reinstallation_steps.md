---
title: Mac Reinstallation Steps
tags: [misc]
keywords: mac, reinstallation
last_updated: Mar 26, 2022
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
$ brew list gawk | grep '/bin/awk'
/usr/local/Cellar/gawk/5.1.0/bin/awk

$ brew list gnu-sed | grep 'bin/sed'
/usr/local/Cellar/gnu-sed/4.8/libexec/gnubin/sed
```

```
awk_path=$(brew list gawk | grep '/bin/awk')
sed_path=$(brew list gnu-sed | grep 'bin/sed')
echo "export PATH=\"${awk_path%/awk}:${sed_path%/sed}:$PATH\"" >> ~/.zshrc
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
- Access System Clipboard (General - Selection - Check `Applications in terminal may access clipboard`)
- Window Transparency (Profile - Window - Transparency `30`)
- Disable Bell (Profile - Terminal - Check `Silence bell`)
- Mac `Option` key for `Alt` in Bash (Profile - Keys - Left/Right Option key `Esc+`)

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
```bash
$ cat /Applications/iTerm.app/Contents/Info.plist | grep -i identifier -A 1
    <key>CFBundleIdentifier</key>
    <string>com.googlecode.iterm2</string>

$ osascript -e 'id of app "Google Chrome"'
com.google.Chrome
```

- Find out Atom Bundle Identifier: com.github.atom
```bash
$ cat /Applications/Atom.app/Contents/Info.plist | grep -i identifier -A 1
    <key>CFBundleIdentifier</key>
    <string>com.github.atom</string>

$ osascript -e 'id of app "Atom"'
com.github.atom
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

#### English / Chinese Mix input
- Update Default Squirrel config
`inline_ascii` 在输入法的临时英文编辑区内输入字母，数字，符号，空格等，回车上屏后自动复位到中文
disable `enter` clear all inputs
```bash
$ diff ~/Library/Rime/default.custom.yaml{,.bak}
39c39
<     good_old_caps_lock: false       # true: 在保持 cap 键原有的特征， false: 点击不会切换大小写
---
>     good_old_caps_lock: true       # true: 在保持 cap 键原有的特征， false: 点击不会切换大小写
42,43c42,43
<       Shift_L: inline_ascii          # macOs 上 shift 键不区别左右，设置参数同上
<       Shift_R: inline_ascii
---
>       Shift_L: commit_code          # macOs 上 shift 键不区别左右，设置参数同上
>       Shift_R: commit_code
64c64
< #      - { when: composing, accept: Return, send: Escape }
---
>       - { when: composing, accept: Return, send: Escape }
```

- Update config for Wubi
```bash
$ diff wubi86_jidian.schema.yaml{,.bak}
56c56
<   max_code_length: 20                    # 四码上屏
---
>   max_code_length: 4                    # 四码上屏
```


### Atom
- install `sync-settings` to sync custom settting (https://atom.io/packages/sync-settings)
  + Gist ID: cbf14a66fee383e153528992cd2cf98e
  + [Link](https://atom.io/packages/search?q=sync-settings)

### Mail Signature

## Optional   
### Prevent GlobalProtect VPN from auto-starting on the Mac
```
sudo sed -i 's/true/false/g' /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist
sudo sed -i 's/true/false/g' /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist
```

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
