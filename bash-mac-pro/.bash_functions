#@IgnoreInspection BashAddShebang

# Show current git branch
parse_git_branch() {
	if [ -z $1 ]; then
		git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
	elif [ $1 -eq 1 ]; then
		git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
	fi
}

# Show current git project name
parse_project_name() {
	git config --local remote.origin.url | perl -p -e "s/.+(?:\/|:)([^.]+)(?:.git)?/\1/"
}

# Run `dig` and display the most useful info
digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# Reload Bash dotfiles
bash_reload() {
	unalias -a 		&& \
	unset -f parse_git_branch digga bash_reload calc && \
	. ~/.profile 	&& \
	printf "\e[0;33mBash reloading ... [\e[0;32mOK\e[0;33m]\e[0m\n"
}

# Calculator
calc() {
    echo "$*" | bc -l;
}
