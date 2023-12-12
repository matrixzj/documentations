---
title: Mac Reinstallation Steps
tags: [misc]
keywords: mac, reinstallation
last_updated: Dec 12, 2023
summary: "Steps to reinstall a workbox for myself"
sidebar: mydoc_sidebar
permalink: misc_mac_reinstallation_steps.html
folder: Misc
---

# Mac Reinstallation Steps
=====

## Backup List 
- SSH Config
- Karabiner Complex Modifications

## Mandantory
### Install Xcode Command Line Tools
[Xcode Command Line Tools](https://developer.apple.com/download/more/)  
[Xcode vs MacOS Compatibility](https://developer.apple.com/support/xcode/)

### Install Brew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
[Homebrew](https://brew.sh/)

### Install zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```
[on-my-zsh github repo](https://github.com/robbyrussell/oh-my-zsh)

### Install tmux
```bash
brew install tmux
```

### Env Config
Git clone from Github to `~/Documents`

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
hostname=""
sudo scutil --set HostName "${hostname}"
sudo scutil --set LocalHostName "${hostname}"
sudo scutil --set ComputerName "${hostname}"
dscacheutil -flushcache
```
reboot to take it in effect

### Install gnu-sed/gawk
```bash
brew install gnu-sed
brew install gawk
```
PATH config   
```bash
$ brew list gnu-sed | grep 'bin/sed'
/usr/local/Cellar/gnu-sed/4.8/libexec/gnubin/sed

$ brew list gawk | grep 'bin/awk'
/usr/local/Cellar/gawk/5.3.0/libexec/gnubin/awk
```

```bash
sed_path=$(brew list gnu-sed | grep 'bin/sed')
awk_path=$(brew list gawk | grep '/bin/awk')
echo "export PATH=\"${awk_path%/awk}:${sed_path%/sed}:$PATH\"" >> ~/.zshrc
```

### Application Install list
* [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
* [iTerm2](https://iterm2.com/downloads.html)
* [Rectangle](https://rectangleapp.com/)
* [Input Method - Squirrel 鼠须管](https://matrixzj.github.io/documentations/misc_mac_reinstallation_steps.html#squirrel-%E9%BC%A0%E9%A1%BB%E7%AE%A1)
* [Visual Studio Code](https://code.visualstudio.com/download)
* [Firefox](https://www.mozilla.org/en-US/firefox/new/)
* [Google Chrome](https://www.google.com/chrome/)
* [IINA](https://iina.io/)
* [Keka](https://www.keka.io/en/)
* [WeChat](https://www.wechat.com/en/)
* QQ ver6.8.2 
* [Discord](https://discord.com/)

Optional
* [coconutBattery](https://www.coconut-flavour.com/coconutbattery/)
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
Launch `System Prereferences`, `Keyboard`, tab `Input Sources`, Add `Squirrel`.  
[Install Wubi jidian Input](https://awesomeopensource.com/project/KyleBing/rime-wubi86-jidian)   
```bash
cd ~/Downloads
git clone https://github.com/KyleBing/rime-wubi86-jidian.git
cp -aRv rime-wubi86-jidian/* ~/Library/Rime
```

#### Enable Chinese Input in `iterm2`
- Find out iTerm2 Bundle Identifier: com.googlecode.iterm2
```bash   
$ cat /Applications/iTerm.app/Contents/Info.plist | grep -i identifier -A 1
    <key>CFBundleIdentifier</key>
    <string>com.googlecode.iterm2</string>

$ $ osascript -e 'id of app "iTerm2"'
com.googlecode.iterm2
```

- Update RIME config  
add folloing block to ~/Library/Rime/squirrel.custom.yaml
```bash
patch:  
  app_options/com.apple.Xcode:   
    ascii_mode: true    
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

## Optional   
### Trust Cert 
- Import CA Cert and private Cert   
- Open `Keychain Access` application and locate the Machine Certificate issued to Mac OS X Client in the System keychain.  
Right-click on the private key associated with Certificate and click Get Info, then go to the Access Control tab   
- Click `+` to select an Application to allow  
- Press key combination `<Command> + <Shift> + G` to open `Go to Folder` in `Finder` Application. Enter `/Applications/GlobalProtect.app/Contents/Resources` and click Go    
- Find `PanGPS` and click it, and then press `Add`    
- Save Changes to private key    

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
