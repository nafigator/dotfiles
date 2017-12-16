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
		api-iledebeaute) echo '_modules/project/api/application.inc.php' ;;
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
		api-iledebeaute) echo "s/current_version = '[^']+/current_version = '$2/g" ;;
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
	printf "\033[0;33mBash reloading ... [\033[0;32mOK\033[0;33m]\033[0m\n"
}

# Calculator
calc() {
	echo "$*" | bc -l;
}

git-test() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	fi

	TEST_BRANCH=$(get_test_branch ${PROJECT_NAME}) && \
	PROD_BRANCH=$(get_prod_branch ${PROJECT_NAME}) && \
	VERSION_FILE=$(get_version_file ${PROJECT_NAME}) && \
	git co ${PROD_BRANCH} && \
	git submodule update && \
	git pull && \
	git co ${TEST_BRANCH} && \
	git submodule update && \
	git pull && \
	git merge --no-edit ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git commit --file .git/MERGE_MSG
	fi && \
	CURRENT_VER=$(git describe) && \
	PROD_VER=$(git describe ${PROD_BRANCH}) && \
	VERSION_ARRAY=(${CURRENT_VER//./ }) && \
	PATCH_ARRAY=(${VERSION_ARRAY[2]//-/ }) && \
	CHECK_VER="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${PATCH_ARRAY[0]}"

	if [ "$CHECK_VER" != "$PROD_VER" ]; then
		VERSION_ARRAY=(${PROD_VER//./ })
		PATCH_ARRAY=(${VERSION_ARRAY[2]//-/ })
	fi

	if [ "${PATCH_ARRAY[1]}" = "dev" ]; then
		DEV_VER=$((${PATCH_ARRAY[2]} + ${PATCH_ARRAY[3]} + 1))
	else
		DEV_VER=$((${PATCH_ARRAY[1]} + 1))
	fi

	NEW_VER="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.${PATCH_ARRAY[0]}-dev-${DEV_VER}" && \
	VERSION_REGEX=$(get_version_regex "$PROJECT_NAME" "$NEW_VER") && \
	perl -pi -e "${VERSION_REGEX}" "${VERSION_FILE}" && \
	git add ${VERSION_FILE} && \
	git ci "Update version" && \
	git push && \
	git t "Release $NEW_VER" ${NEW_VER} && \
	git push --tags && \
	git co ${BRANCH_NAME} && \
	git submodule update && \
	unset BRANCH_NAME PROJECT_NAME TEST_BRANCH DEV_VER VERSION_REGEX NEW_VER PATCH_ARRAY VERSION_ARRAY CHECK_VER PROD_VER CURRENT_VER OUTPUT
}

git-prod() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	else
		PROD_BRANCH=$(get_prod_branch ${PROJECT_NAME})
	fi && \
	git pull --rebase origin ${PROD_BRANCH} && \
	git co ${PROD_BRANCH} && \
	git pull && \
	git rebase ${BRANCH_NAME} && \
	git submodule update && \
	git br -d ${BRANCH_NAME} && \
	git push && \
	git describe 2>/dev/null
	unset BRANCH_NAME PROJECT_NAME PROD_BRANCH
}

git-prod-patch() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	fi

	TEST_BRANCH=$(get_test_branch ${PROJECT_NAME}) && \
	PROD_BRANCH=$(get_prod_branch ${PROJECT_NAME}) && \
	VERSION_FILE=$(get_version_file ${PROJECT_NAME}) && \
	git co ${PROD_BRANCH} && \
	git pull && \
	CURRENT_VER=$(git tag | sort -V | tail -n 1) && \
	git co ${BRANCH_NAME} && \
	VERSION_ARRAY=(${CURRENT_VER//./ }) && \
	PATCH_ARRAY=(${VERSION_ARRAY[2]//-/ }) && \
	PATCH_VER=$((${PATCH_ARRAY[0]} + 1)) && \
	NEW_VER="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.$PATCH_VER" && \
	VERSION_REGEX=$(get_version_regex "${PROJECT_NAME}" "${NEW_VER}") && \
	perl -pi -e "${VERSION_REGEX}" "${VERSION_FILE}" && \
	git add ${VERSION_FILE} && \
	git ci "Update version" && \
	git co ${TEST_BRANCH} && \
	git submodule update && \
	git pull && \
	git merge ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	git submodule update && \
	git pull --rebase origin ${PROD_BRANCH}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git co ${PROD_BRANCH} && \
	git submodule update && \
	git pull && \
	git rebase ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git submodule update && \
	git br -d ${BRANCH_NAME} && \
	git push && \
	git t "Release $NEW_VER" ${NEW_VER} && \
	git push --tags && \
	git describe 2>/dev/null
	unset BRANCH_NAME PROJECT_NAME CURRENT_VER VERSION_ARRAY PATCH_VER TEST_BRANCH PROD_BRANCH VERSION_FILE VERSION_REGEX OUTPUT
}

git-prod-minor() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	fi

	TEST_BRANCH=$(get_test_branch ${PROJECT_NAME}) && \
	PROD_BRANCH=$(get_prod_branch ${PROJECT_NAME}) && \
	VERSION_FILE=$(get_version_file ${PROJECT_NAME}) && \
	git co ${PROD_BRANCH} && \
	git pull && \
	CURRENT_VER=$(git tag | sort -V | tail -n 1) && \
	git co ${BRANCH_NAME} && \
	VERSION_ARRAY=(${CURRENT_VER//./ }) && \
	MINOR_VER=$((${VERSION_ARRAY[1]} + 1)) && \
	NEW_VER="${VERSION_ARRAY[0]}.$MINOR_VER.0" && \
	VERSION_REGEX=$(get_version_regex "${PROJECT_NAME}" "${NEW_VER}") && \
	perl -pi -e "${VERSION_REGEX}" "${VERSION_FILE}" && \
	git add ${VERSION_FILE} && \
	git ci "Update version" && \
	git co ${TEST_BRANCH} && \
	git submodule update && \
	git pull && \
	git merge ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	git submodule update && \
	git pull --rebase origin ${PROD_BRANCH}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git co ${PROD_BRANCH} && \
	git submodule update && \
	git pull && \
	git rebase ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git submodule update && \
	git br -d ${BRANCH_NAME} && \
	git push && \
	git t "Release $NEW_VER" ${NEW_VER} && \
	git push --tags && \
	git describe 2>/dev/null
	unset BRANCH_NAME PROJECT_NAME CURRENT_VER VERSION_ARRAY MINOR_VER TEST_BRANCH PROD_BRANCH VERSION_FILE VERSION_REGEX OUTPUT
}

git-prod-major() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	fi

	TEST_BRANCH=$(get_test_branch ${PROJECT_NAME}) && \
	PROD_BRANCH=$(get_prod_branch ${PROJECT_NAME}) && \
	VERSION_FILE=$(get_version_file ${PROJECT_NAME}) && \
	git co ${PROD_BRANCH} && \
	git pull && \
	CURRENT_VER=$(git tag | sort -V | tail -n 1) && \
	git co ${BRANCH_NAME} && \
	VERSION_ARRAY=(${CURRENT_VER//./ }) && \
	MAJOR_VER=$((${VERSION_ARRAY[0]} + 1)) && \
	NEW_VER="$MAJOR_VER.0.0" && \
	VERSION_REGEX=$(get_version_regex "${PROJECT_NAME}" "${NEW_VER}") && \
	perl -pi -e "${VERSION_REGEX}" "${VERSION_FILE}" && \
	git add ${VERSION_FILE} && \
	git ci "Update version" && \
	git co ${TEST_BRANCH} && \
	git submodule update && \
	git pull && \
	git merge ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	git submodule update && \
	git pull --rebase origin ${PROD_BRANCH}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git co ${PROD_BRANCH} && \
	git submodule update && \
	git pull && \
	git rebase ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			error "Conflict in non-version files!"
			return 1
		fi

		inform "Conflict in version file."
		inform "Trying to resolve..."

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git submodule update && \
	git br -d ${BRANCH_NAME} && \
	git push && \
	git t "Release $NEW_VER" ${NEW_VER} && \
	git push --tags && \
	git describe 2>/dev/null
	unset BRANCH_NAME PROJECT_NAME CURRENT_VER VERSION_ARRAY MINOR_VER TEST_BRANCH PROD_BRANCH VERSION_FILE VERSION_REGEX OUTPUT
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
