#!/usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
GRAY="\e[38;5;242m"
BOLD="\e[1m"
CLR="\e[0m"
DEBUG=
STATUS_LENGTH=60

# Screen cleanup
c() {
	printf "\033c";
	[[ "$(uname -s)" == "Linux" ]] && env TERM=linux setterm -regtabs 4
}

# Function for datetime output
format_date() {
	printf "$GRAY$(date +'%Y-%m-%d %H:%M:%S')$CLR"
}

# Function for error messages
error() {
	printf "[$(format_date)]: ${RED}ERROR:$CLR $@\n" >&2
}

# Function for informational messages
inform() {
	printf "[$(format_date)]: ${GREEN}INFO:$CLR $@\n"
}

# Function for warning messages
warning() {
	printf "[$(format_date)]: ${YELLOW}WARNING:$CLR $@\n" >&2
}

# Function for debug messages
debug() {
	[ ! -z ${DEBUG} ] && printf "[$(format_date)]: ${GREEN}DEBUG:$CLR $@\n"
}

# Function for operation status
#
# Usage: status MESSAGE STATUS
# Examples:
# status 'Upload scripts' $?
# status 'Run operation' OK
status() {
	if [ -z "$1" ] || [ -z "$2" ]; then
		error "status(): not found required parameters!"
		return 1
	fi

	local result=0

	if [ $2 = 'OK' ]; then
		printf "[$(format_date)]: %-${STATUS_LENGTH}b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 = 'FAIL' ]; then
		printf "[$(format_date)]: %-${STATUS_LENGTH}b[$RED%s$CLR]\n" "$1" "FAIL"
		result=1
	elif [ $2 = 0 ]; then
		printf "[$(format_date)]: %-${STATUS_LENGTH}b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 -gt 0 ]; then
		printf "[$(format_date)]: %-${STATUS_LENGTH}b[$RED%s$CLR]\n" "$1" "FAIL"
		result=1
	fi

	return ${result}
}

# Function for status on some command in debug mode only
status_dbg() {
	[ -z ${DEBUG} ] && return 0

	if [ -z "$1" ] || [ -z "$2" ]; then
		error "status_dbg(): not found required parameters!"
		return 1
	fi

	local length=$(( ${STATUS_LENGTH} - 7 ))
	local result=0

	#debug "status_dbg length: $length"

	if [ $2 = 'OK' ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-${length}b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 = 'FAIL' ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-${length}b[$RED%s$CLR]\n" "$1" "FAIL"
	elif [ $2 = 0 ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-${length}b[$GREEN%s$CLR]\n" "$1" "OK"
	elif [ $2 -gt 0 ]; then
		printf "[$(format_date)]: ${GREEN}DEBUG:$CLR %-${length}b[$RED%s$CLR]\n" "$1" "FAIL"
		result=1
	fi

	return ${result}
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
	unalias -a && \
	unset -f c error inform warning parse_git_branch digga bash-reload calc && \
	. $HOME/.profile && \
	status 'Bash reload' $?
}

# Calculator
calc() {
    echo "$*" | bc -l;
}
