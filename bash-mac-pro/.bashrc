#@IgnoreInspection BashAddShebang
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export PAGER=less

# Set special theme for root editor and file manager
if [ $(id -u) -ne 0 ]; then
	MC_SKIN='modarin256'
else
	MC_SKIN='modarin256root'
fi

export MC_SKIN

# Set default editor
export EDITOR=mcedit

# Set less options
export LESS='-MFRX -x4'

# Flag terminal as color-capable
export TERM=xterm-256color

# Tabs size
[ $(uname -s) != 'OpenBSD' ] && tabs -4 +m0

# OpenBSD specific variables
if [ $(uname -s) = 'OpenBSD' ]; then
	# Official OpenBSD mirror
	# export PKG_PATH=ftp://ftp.OpenBSD.org/pub/OpenBSD/5.7/packages/amd64/

	# Yandex mirror
	#export PKG_PATH=ftp://mirror.yandex.ru/pub/OpenBSD/5.7/packages/amd64/
	export PKG_PATH=http://mirror.yandex.ru/pub/OpenBSD/5.7/packages/amd64/
fi

# Functions definitions
if [ -f ~/.bash_functions ]; then
	. ~/.bash_functions
fi

PS1='\u@\h:\[\e[1;32m\]$(parse_git_branch 1)\[\e[0m\]\w\$ '

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# Show tasks
if [ $(uname -s) != 'OpenBSD' ]; then
	export task_count='\[\e[0;33m\]$(t | wc -l | sed -e "s/^ *\([1-9][0-9]*\)$/[\1] /" -e "s/^ *0$//")\[\e[0m\]'
	export PS1="$task_count$PS1"
	unset task_count
fi
