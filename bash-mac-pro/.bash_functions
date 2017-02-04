#@IgnoreInspection BashAddShebang

# Screen cleanup
c() {
	printf "\033c";
	[[ "$(uname -s)" == "Linux" ]] && env TERM=linux setterm -regtabs 4
}
# Function for error
err() {
	printf "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: \033[0;31mERROR:\033[0m $@\n" >&2
}

# Function for informational messages
inform() {
	printf "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: \033[0;32mINFO:\033[0m $@\n"
}

# Function for warning messages
warn() {
	printf "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: \033[0;33mWARNING:\033[0m $@\n" >&2
}

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
bash-reload() {
	unalias -a 		&& \
	unset -f c err inform warn parse_git_branch digga bash_reload calc && \
	. ~/.profile 	&& \
	printf "\e[0;33mBash reloading ... [\e[0;32mOK\e[0;33m]\e[0m\n"
}

# Calculator
calc() {
    echo "$*" | bc -l;
}
