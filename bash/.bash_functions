#!/usr/bin/env bash

# Screen cleanup
c() {
	printf "\033c";
	[[ $(uname -s) == "Linux" ]] && env TERM=linux setterm -regtabs 4
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
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
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
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
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
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
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
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
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
bash_reload() {
	unalias -a 		&& \
	unset -f c parse_git_branch parse_project_name get_test_branch get_prod_branch get_version_file get_version_regex digga bash_reload calc api_get api_post api_put git-test git-prod git-prod-patch git-prod-minor && \
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
		options="--data-binary $1 http://api.lo$2"
	fi

	c && \
	curl -i \
		--request GET \
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
	c && \
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
	c && \
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

api_del() {
	if [ -z $1 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	if [ -z $2 ]; then
		options="http://api.lo$1"
	else
		options="--data-binary $1 http://api.lo$2"
	fi

	c && \
	curl -i \
		--request DELETE \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp/1.3.3 (curl request) API/0.0" \
		${options}
	echo
}

git-test() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	else
		TEST_BRANCH=$(get_test_branch ${PROJECT_NAME})
	fi && \
	git co ${TEST_BRANCH} && \
	git pull && \
	git merge ${BRANCH_NAME} && \
	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	unset BRANCH_NAME PROJECT_NAME TEST_BRANCH
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
	CURRENT_VER=$(git tag | sort -V | tail -n 1) && \
	VERSION_ARRAY=(${CURRENT_VER//./ }) && \
	PATCH_VER=$((${VERSION_ARRAY[2]} + 1)) && \
	NEW_VER="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.$PATCH_VER" && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	else
		TEST_BRANCH=$(get_test_branch ${PROJECT_NAME})
		PROD_BRANCH=$(get_prod_branch ${PROJECT_NAME})
		VERSION_FILE=$(get_version_file ${PROJECT_NAME})
		VERSION_REGEX=$(get_version_regex ${PROJECT_NAME} ${NEW_VER})
	fi && \
	perl -pi -e "${VERSION_REGEX}" "${VERSION_FILE}" && \
	git add ${VERSION_FILE} && \
	git ci "Update version" && \
	git co ${TEST_BRANCH} && \
	git pull && \
	git merge ${BRANCH_NAME} && \
	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	git pull --rebase origin ${PROD_BRANCH} && \
	git co ${PROD_BRANCH} && \
	git pull && \
	git rebase ${BRANCH_NAME} && \
	git submodule update && \
	git br -d ${BRANCH_NAME} && \
	git push && \
	git t "Release $NEW_VER" ${NEW_VER} && \
	git push --tags && \
	git describe 2>/dev/null
	unset BRANCH_NAME PROJECT_NAME CURRENT_VER VERSION_ARRAY PATCH_VER TEST_BRANCH PROD_BRANCH VERSION_FILE VERSION_REGEX
}

git-prod-minor() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	CURRENT_VER=$(git tag | sort -V | tail -n 1) && \
	VERSION_ARRAY=(${CURRENT_VER//./ }) && \
	MINOR_VER=$((${VERSION_ARRAY[1]} + 1)) && \
	NEW_VER="${VERSION_ARRAY[0]}.$MINOR_VER.0" && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	else
		TEST_BRANCH=$(get_test_branch ${PROJECT_NAME})
		PROD_BRANCH=$(get_prod_branch ${PROJECT_NAME})
		VERSION_FILE=$(get_version_file ${PROJECT_NAME})
		VERSION_REGEX=$(get_version_regex ${PROJECT_NAME} ${NEW_VER})
	fi && \
	perl -pi -e "${VERSION_REGEX}" "${VERSION_FILE}" && \
	git add ${VERSION_FILE} && \
	git ci "Update version" && \
	git co ${TEST_BRANCH} && \
	git pull && \
	git merge ${BRANCH_NAME} && \
	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	git pull --rebase origin ${PROD_BRANCH} && \
	git co ${PROD_BRANCH} && \
	git pull && \
	git rebase ${BRANCH_NAME} && \
	git submodule update && \
	git br -d ${BRANCH_NAME} && \
	git push && \
	git t "Release $NEW_VER" ${NEW_VER} && \
	git push --tags && \
	git describe 2>/dev/null
	unset BRANCH_NAME PROJECT_NAME CURRENT_VER VERSION_ARRAY MINOR_VER TEST_BRANCH PROD_BRANCH VERSION_FILE VERSION_REGEX
}

api-dredd() {
	APIB_FILE="$HOME/api/tests/iledebeaute.apib"
	if [ ! -r "$APIB_FILE" ]; then
		printf "\033[0;31mERROR:\033[0m Not found apib-file!\n"
		return 1
	fi

	mysql -uroot zs_ru_etoya -se "DELETE FROM core_user WHERE email = 'unique_889988_addr@domain.ru'"
	mysql -uroot zs_ru_etoya -se "DELETE FROM user_mail WHERE m_mail = 'unique_009988_addr@domain.ru' AND i_user_id = 1"
	mysql -uroot zs_ru_etoya -se "INSERT IGNORE user_mail VALUES (1, 'unique_997799_addr@domain.ru', 1455026420, 1455026420, ''),(1, 'unique_338899_addr@domain.ru', 1455026420, 0, '')"
	mysql -uroot zs_ru_etoya -se  "
		DELETE FROM store_user_order where i_id = 631224;
		DELETE FROM store_user_order_gift_list where i_ref_id = 631224;
		DELETE FROM store_user_order_list WHERE i_ref_id = 631224;
		REPLACE INTO store_user_order VALUES
			(631224, '0cf54bd01ca0ff829773de3070096222f389fd3d', 1455542832, 1455792111, null, 0, 2310, 2310, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 0, null);
		REPLACE INTO store_user_order_list VALUES
			(1963895, 631224, 15510, 2310, 2310, null, 1, 1455791602, 14830, 37694, 0);
		REPLACE INTO store_user_order_list VALUES
			(1963896, 631224, 101037, 3860, 3860, null, 1, 1455791602, 14830, 85675, -1)"

	cd "$HOME/api"
	dredd ${APIB_FILE}
	cd - >/dev/null
}
