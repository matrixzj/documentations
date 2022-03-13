---
title: Python Virtual Environment
tags: [python]
keywords: python, virtual environment, multi-versions, pyenv
last_updated: July 7, 2020
summary: "How to install Python Virtual Enviroment on CentOS7 with PyEnv"
sidebar: mydoc_sidebar
permalink: python_virtual_env.html
folder: python
---


# Python Virtual Environment
=====


## Prequist

```
$ sudo yum -y install epel-release
$ sudo yum install git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
```

## Install PyEnv from GitHub
```
$ git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
```

## Update Bash Env Config
```
$ cat << EOF >> $HOME/.bashrc
## pyenv configs
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
EOF

# source $HOME/.bashrc
```

## List available Python Versions and Install 
```
$ pyenv install -l
Available versions:
  2.1.3
  2.2.3
  2.3.7
  2.4.0
  2.4.1
  2.4.2
  2.4.3
  2.4.4
  2.4.5
  2.4.6
...

$ pyenv install 3.7.6
Installing Python-3.7.6...
Installed Python-3.7.6 to /home/jzou/.pyenv/versions/3.7.6
```

## Install pyenv-virtualenv plugin and add config in `.bashrc`
```
$ git clone https://github.com/yyuu/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv

$ cat << EOF >> $HOME/.bashrc
### python virtual env config
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

$ source .bashrc
```

## List Installed Python Versions 
```
$ pyenv versions
* system (set by /home/jzou/.pyenv/version)
  3.7.6
```

## Create Virtual Env with Installed Python Version
```
 $ pyenv virtualenv 3.7.6 learning
Looking in links: /tmp/tmp16s1axfi
Requirement already satisfied: setuptools in /home/jzou/.pyenv/versions/3.7.6/envs/learning/lib/python3.7/site-packages (41.2.0)
Requirement already satisfied: pip in /home/jzou/.pyenv/versions/3.7.6/envs/learning/lib/python3.7/site-packages (19.2.3)

$ pyenv versions
* system (set by /home/jzou/.pyenv/version)
  3.7.6
  3.7.6/envs/learning
  learning

$ pyenv activate learning
pyenv-virtualenv: prompt changing will be removed from future release. configure `export PYENV_VIRTUALENV_DISABLE_PROMPT=1' to simulate the behavior.
(learning)
```

## De-Activate Virtual Env
```
$ pyenv deactivate
```

[Pyenv – Install Multiple Python Versions for Specific Project](https://www.tecmint.com/pyenv-install-and-manage-multiple-python-versions-in-linux/)

{% include links.html %}
