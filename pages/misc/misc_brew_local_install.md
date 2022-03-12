---
title: Brew Install from a Local Source
tags: [misc]
keywords: mac, brew
last_updated: Mar 30, 2020
summary: "brew installation from local source"
sidebar: mydoc_sidebar
permalink: misc_brew_local_install.html
folder: Misc
---

# Brew Install from a Local Source
======

## add repo with `brew tap`

```
$ brew tap jeffreywildman/homebrew-virt-manager
Updating Homebrew...
==> Tapping jeffreywildman/virt-manager
Cloning into '/usr/local/Homebrew/Library/Taps/jeffreywildman/homebrew-virt-manager'...
remote: Enumerating objects: 41, done.
remote: Counting objects: 100% (41/41), done.
remote: Compressing objects: 100% (25/25), done.
remote: Total 524 (delta 19), reused 36 (delta 16), pack-reused 483
Receiving objects: 100% (524/524), 98.41 KiB | 102.00 KiB/s, done.
Resolving deltas: 100% (311/311), done.
Tapped 4 formulae (29 files, 144.6KB).
```

## update related ruby config file
```
$ ls -al  /usr/local/Homebrew/Library/Taps/jeffreywildman/homebrew-virt-manager
total 40
drwxr-xr-x   8 jzou  admin   256 Mar 30 15:30 .
drwxr-xr-x   3 jzou  admin    96 Mar 30 15:30 ..
drwxr-xr-x  12 jzou  admin   384 Mar 30 15:35 .git
-rw-r--r--   1 jzou  admin  1836 Mar 30 15:30 README.md
-rw-r--r--   1 jzou  admin   748 Mar 30 15:30 osinfo-db-tools.rb
-rw-r--r--   1 jzou  admin   524 Mar 30 15:30 osinfo-db.rb
-rw-r--r--   1 jzou  admin  3797 Mar 30 15:30 virt-manager.rb
-rw-r--r--   1 jzou  admin  1333 Mar 30 15:30 virt-viewer.rb

$ git diff /usr/local/Homebrew/Library/Taps/jeffreywildman/homebrew-virt-manager/virt-manager.rb
diff --git a/virt-manager.rb b/virt-manager.rb
index 64bd2e1..5bf20b2 100644
--- a/virt-manager.rb
+++ b/virt-manager.rb
@@ -3,7 +3,7 @@ class VirtManager < Formula

   desc "App for managing virtual machines"
      homepage "https://virt-manager.org/"
      -  url "https://virt-manager.org/download/sources/virt-manager/virt-manager-2.2.1.tar.gz"
      +  url "file:///Users/jzou/Downloads/virt-manager-2.2.1.tar.gz"
         sha256 "cfd88d66e834513e067b4d3501217e21352fadb673103bacb9e646da9f029a1b"
            revision 3
```

## install with `brew install` as normal installation process
```
$ brew install virt-manager
```

{% include links.html %}
