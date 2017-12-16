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

# Function for checking script dependencies
check_dependencies() {
	local result=0
	local cmd_status

	for i in ${@}; do
		command -v ${i} >/dev/null 2>&1
		cmd_status=$?

		#status_dbg "DEPENDENCY: $i" ${cmd_status}

		if [ ${cmd_status} -ne 0 ]; then
			warning "$i command not available"
			result=1
		fi
	done

	#debug "check_dependencies() result: $result"

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

# Show development branch name for current project
get_test_branch() {
	if [ -z $1 ]; then
		error "Not found required parameters!"
		return 1
	fi

	case $1 in
		Veles) echo 'development' ;;
		*)     echo 'test' ;;
	esac
}

# Show production branch name for current project
get_prod_branch() {
	if [ -z $1 ]; then
		error "Not found required parameters!"
		return 1
	fi

	case $1 in
		Veles|itvault) echo 'master' ;;
		*)     echo 'prod' ;;
	esac
}

# Show production branch name for current project
get_version_file() {
	if [ -z $1 ]; then
		error "Not found required parameters!"
		return 1
	fi

	case $1 in
		Veles) echo 'README.md' ;;
		*) echo 'version.ini' ;;
	esac
}

# Show version regular expression
get_version_regex() {
	if [ -z $1 ] || [ -z $2 ]; then
		error "Not found required parameters!"
		return 1
	fi

	case $1 in
		Veles) echo "s/badge\/release-[^-]+/badge\/release-$2/g" ;;
		*) echo "s/current_version = [^\s]+/current_version = $2/g" ;;
	esac
}

# Run `dig` and display the most useful info
digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# Reload Bash dotfiles
bash-reload() {
	unalias -a 		&& \
	unset -f c error inform warning parse_git_branch parse_project_name get_test_branch get_prod_branch get_version_file get_version_regex digga bash-reload calc git-test git-prod git-prod-patch git-prod-minor webon weboff && \
	. $HOME/.xsessionrc	&& \
	status 'Bash reload' $?
}

# Calculator
calc() {
	echo "$*" | bc -l;
}

git-test() {
	local branch_name="$(parse_git_branch)"
	local project_name="$(parse_project_name)"

	if [ -z "$project_name" ] || [ -z "$branch_name" ]; then
		return 1
	fi

	local test_branch="$(get_test_branch "$project_name")" && \
	local prod_branch="$(get_prod_branch "$project_name")" && \
	local version_file="$(get_version_file "$project_name")" && \
	git co "$prod_branch" && \
	git submodule update && \
	git pull && \
	git co "$test_branch" && \
	git submodule update && \
	git pull && \
	git merge "$branch_name"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			err "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git commit --file .git/MERGE_MSG
	fi && \
	local current_ver="$(git describe)" && \
	local prod_ver="$(git describe "$prod_branch")" && \
	local version_array=(${current_ver//./ }) && \
	local patch_array=(${version_array[2]//-/ }) && \
	local check_ver="${version_array[0]}.${version_array[1]}.${patch_array[0]}"
	local dev_ver=

	if [ "$check_ver" != "$prod_ver" ]; then
		local version_array=(${prod_ver//./ })
		local patch_array=(${version_array[2]//-/ })
	fi

	if [ "${patch_array[1]}" = "dev" ]; then
		dev_ver=$((${patch_array[2]} + ${patch_array[3]} + 1))
	else
		dev_ver=$((${patch_array[1]} + 1))
	fi

	local new_ver="${version_array[0]}.${version_array[1]}.${patch_array[0]}-dev-${dev_ver}" && \
	local version_regex=$(get_version_regex "$project_name" "$new_ver") && \
	perl -pi -e "${version_regex}" "${version_file}" && \
	git add "$version_file" && \
	git ci "Update version" && \
	git push && \
	git t "Release $new_ver" "$new_ver" && \
	git push --tags && \
	git co "$branch_name" && \
	git submodule update
}

git-prod() {
	local branch_name="$(parse_git_branch)"
	local project_name="$(parse_project_name)"
	local prod_branch=

	if [ -z "$project_name" ] || [ -z "$branch_name" ]; then
		return 1
	else
		prod_branch="$(get_prod_branch "$project_name")"
	fi

	git pull --rebase origin "$prod_branch" && \
	git co "$prod_branch" && \
	git pull && \
	git rebase "$branch_name" && \
	git submodule update && \
	git br -d "$branch_name" && \
	git push && \
	git describe 2>/dev/null
}

git-prod-patch() {
	local branch_name="$(parse_git_branch)" && \
	local project_name="$(parse_project_name)" && \
	if [ -z "$project_name" ] || [ -z "$branch_name" ]; then
		return 1
	fi

	local test_branch="$(get_test_branch "$project_name")" && \
	local prod_branch="$(get_prod_branch "$project_name")" && \
	local version_file="$(get_version_file "$project_name")" && \
	git co "$prod_branch" && \
	git pull && \
	local current_ver="$(git tag | sort -V | tail -n 1)" && \
	git co "$branch_name" && \
	local version_array=(${current_ver//./ }) && \
	local patch_array=(${version_array[2]//-/ }) && \
	local patch_ver=$((${patch_array[0]} + 1)) && \
	local new_ver="${version_array[0]}.${version_array[1]}.$patch_ver" && \
	local version_regex="$(get_version_regex "${project_name}" "${new_ver}")" && \
	perl -pi -e "${version_regex}" "${version_file}" && \
	git add "$version_file" && \
	git ci "Update version" && \
	git co "$test_branch" && \
	git submodule update && \
	git pull && \
	git merge "$branch_name"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			err "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co "$branch_name" && \
	git submodule update && \
	git pull --rebase origin "$prod_branch"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			err "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git rebase --continue
	fi

	git co "$prod_branch" && \
	git submodule update && \
	git pull && \
	git rebase "$branch_name"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			err "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git rebase --continue
	fi

	git submodule update && \
	git br -d "$branch_name" && \
	git push && \
	git t "Release $new_ver" "$new_ver" && \
	git push --tags && \
	git describe 2>/dev/null
}

git-prod-minor() {
	local branch_name="$(parse_git_branch)" && \
	local project_name="$(parse_project_name)" && \
	if [ -z "$project_name" ] || [ -z "$branch_name" ]; then
		return 1
	fi

	local test_branch="$(get_test_branch "$project_name")" && \
	local prod_branch="$(get_prod_branch "$project_name")" && \
	local version_file="$(get_version_file "$project_name")" && \
	git co "$prod_branch" && \
	git pull && \
	local current_ver="$(git tag | sort -V | tail -n 1)" && \
	git co "$branch_name" && \
	local version_array=(${current_ver//./ }) && \
	local minor_ver=$((${version_array[1]} + 1)) && \
	local new_ver="${version_array[0]}.$minor_ver.0" && \
	local version_regex="$(get_version_regex "${project_name}" "${new_ver}")" && \
	perl -pi -e "${version_regex}" "${version_file}" && \
	git add "$version_file" && \
	git ci "Update version" && \
	git co "$test_branch" && \
	git submodule update && \
	git pull && \
	git merge "$branch_name"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co "$branch_name" && \
	git submodule update && \
	git pull --rebase origin "$prod_branch"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git rebase --continue
	fi

	git co "$prod_branch" && \
	git submodule update && \
	git pull && \
	git rebase "$branch_name"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git rebase --continue
	fi

	git submodule update && \
	git br -d "$branch_name" && \
	git push && \
	git t "Release $new_ver" "$new_ver" && \
	git push --tags && \
	git describe 2>/dev/null
}

git-prod-major() {
	local branch_name="$(parse_git_branch)" && \
	local project_name="$(parse_project_name)" && \
	if [ -z "$project_name" ] || [ -z "$branch_name" ]; then
		return 1
	fi

	local test_branch="$(get_test_branch "$project_name")" && \
	local prod_branch="$(get_prod_branch "$project_name")" && \
	local version_file="$(get_version_file "$project_name")" && \
	git co "$prod_branch" && \
	git pull && \
	local current_ver="$(git tag | sort -V | tail -n 1)" && \
	git co "$branch_name" && \
	local version_array=(${current_ver//./ }) && \
	local major_ver=$((${version_array[0]} + 1)) && \
	local new_ver="$major_ver.0.0" && \
	local version_regex=$(get_version_regex "${project_name}" "${new_ver}") && \
	perl -pi -e "${version_regex}" "${version_file}" && \
	git add "$version_file" && \
	git ci "Update version" && \
	git co "$test_branch" && \
	git submodule update && \
	git pull && \
	git merge "$branch_name"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co "$branch_name" && \
	git submodule update && \
	git pull --rebase origin "$prod_branch"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git rebase --continue
	fi

	git co "$prod_branch" && \
	git submodule update && \
	git pull && \
	git rebase "$branch_name"

	if [ ! $? -eq 0 ]; then
		local output="$(git st | grep UU)"

		if [ "$output" != "UU $version_file" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs "$version_file" && \
		git add "$version_file"
		git rebase --continue
	fi

	git submodule update && \
	git br -d "$branch_name" && \
	git push && \
	git t "Release $new_ver" "$new_ver" && \
	git push --tags && \
	git describe 2>/dev/null
}

webon() {
	local output
	local result

	output=$(sudo service mysql start 2>&1)
	result=$?

	status "Start mysql" ${result}

	[ ${result} -ne 0 ] && error "$output"

	output=$(sudo service php7.0-fpm start 2>&1)
	result=$?

	status "Start php7.0-fpm" ${result}

	[ ${result} -ne 0 ] && error "$output"

	output=$(sudo service nginx start 2>&1)
	result=$?

	status "Start nginx" ${result}

	[ ${result} -ne 0 ] && error "$output"
}

weboff() {
	local output
	local result

	output=$(sudo service mysql stop 2>&1)
	result=$?

	status "Stop mysql" ${result}

	[ ${result} -ne 0 ] && error "$output"

	output=$(sudo service php7.0-fpm stop 2>&1)
	result=$?

	status "Stop php7.0-fpm" ${result}

	[ ${result} -ne 0 ] && error "$output"

	output=$(sudo service nginx stop 2>&1)
	result=$?

	status "Stop nginx" $?

	[ ${result} -ne 0 ] && error "$output"

	output=$(sudo service memcached stop 2>&1)
	result=$?

	status "Stop memcache" ${result}

	[ ${result} -ne 0 ] && error "$output"

	output=$(sudo service gearman-job-server stop 2>&1)
	result=$?

	status "Stop gearman" ${result}

	[ ${result} -ne 0 ] && error "$output"
}
