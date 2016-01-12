#!/usr/bin/env bash
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
	unset -f parse_git_branch digga bash_reload calc api_get api_post api_put && \
	. ~/.xsessionrc	&& \
	printf "\033[0;33mBash reloading ... [\033[0;32mOK\033[0;33m]\033[0m\n"
}

# Calculator
calc() {
	echo "$*" | bc -l;
}

# Aliases for testing API with curl
api_get() {
	if [ -z $1 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	if [ -z $2 ]; then
		options="http://api.lo$1"
	else
		options="--data-binary \"$1\" http://api.lo$2"
	fi

	printf "\033c" && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp/1.3.3 (curl request) API/0.0" \
		${options}
	echo
}

api_post() {
	if [ -z $1 ] || [ -z $2 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	printf "\033c" && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp/1.3.3 (curl request) API/0.0" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.lo$2
	echo
}

api_put() {
	if [ -z $1 ] || [ -z $2 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	printf "\033c" && \
	curl -i \
		-X PUT \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp/1.3.3 (curl request) API/0.0" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.lo$2
	echo
}
