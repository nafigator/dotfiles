# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export EDITOR=mcedit
export PAGER=less
# Set less options
export LESS='-FRX -x4'

# Tabs size
tabs -4 +m0

# Show current git branch
parse_git_branch() {
	git branch 2> /dev/null | gsed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

PS1='\u@\h:\[\e[1;32m\]$(parse_git_branch)\[\e[0m\]\w\$ '

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# Show tasks
export task_count='\[\e[0;33m\][$(t | wc -l | sed -e"s/ *//")]\[\e[0m\]'
export PS1="$task_count $PS1"
unset task_count
