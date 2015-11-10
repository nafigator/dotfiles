#@IgnoreInspection BashAddShebang

# Show current git branch
parse_git_branch() {
	git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

# Run `dig` and display the most useful info
digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# Reload Bash dotfiles
bash_reload() {
	unalias -a 		&& \
	unset -f parse_git_branch digga bash_reload calc api_get api_post && \
	. ~/.xsessionrc	&& \
	printf "\e[0;33mBash reloading ... [\e[0;32mOK\e[0;33m]\e[0m\n"
}

# Calculator
calc() {
	echo "$*" | bc -l;
}

# Aliases for testing API with curl
api_get() {
	echo -e "\033\0143" && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "Iledebeaute Mobile Application/4.3.3 API/0.0.2" \
		http://api.lo$1
	echo
}

api_post() {
	echo -e "\033\0143" && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "Iledebeaute Mobile Application/4.3.3 API/0.0.2" \
		--header "Content-Type: application/x-www-form-urlencoded" \
		--data "$1" \
		http://api.lo$2
	echo
}
