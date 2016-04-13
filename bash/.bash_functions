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
bash-reload() {
	unalias -a 		&& \
	unset -f c parse_git_branch parse_project_name get_test_branch get_prod_branch get_version_file get_version_regex digga bash-reload calc api-get api-post api-put api-del api-test-get api-test-post api-test-put api-test-del git-test git-prod git-prod-patch git-prod-minor && \
	. ~/.xsessionrc	&& \
	printf "\033[0;33mBash reloading ... [\033[0;32mOK\033[0;33m]\033[0m\n"
}

# Calculator
calc() {
	echo "$*" | bc -l;
}

# Aliases for testing API with curl
api-get() {
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
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		${options}
	echo
}

api-post() {
	if [ -z $1 ] || [ -z $2 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	c && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.lo$2
	echo
}

api-put() {
	if [ -z $1 ] || [ -z $2 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	c && \
	curl -i \
		-X PUT \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.lo$2
	echo
}

api-del() {
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
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		${options}
	echo
}

# Aliases for testing API with curl
api-test-get() {
	if [ -z $1 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	if [ -z $2 ]; then
		options="http://api.etoya.ru.zerostudio.ru$1"
	else
		options="--data-binary $1 http://api.lo$2"
	fi

	c && \
	curl -i \
		--request GET \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		${options}
	echo
}

api-test-post() {
	if [ -z $1 ] || [ -z $2 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	c && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.etoya.ru.zerostudio.ru$2
	echo
}

api-test-put() {
	if [ -z $1 ] || [ -z $2 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	c && \
	curl -i \
		-X PUT \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.etoya.ru.zerostudio.ru$2
	echo
}

api-test-del() {
	if [ -z $1 ]; then
		printf "\033[0;31mERROR:\033[0m Not found required parameters!\n"
		return 1
	fi
	if [ -z $2 ]; then
		options="http://api.etoya.ru.zerostudio.ru$1"
	else
		options="--data-binary $1 http://api.lo$2"
	fi

	c && \
	curl -i \
		--request DELETE \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0) API/0.3" \
		${options}
	echo
}

git-test() {
	BRANCH_NAME=$(parse_git_branch) && \
	PROJECT_NAME=$(parse_project_name) && \
	if [ -z ${PROJECT_NAME} ] || [ -z ${BRANCH_NAME} ]; then
		return 1
	fi

	TEST_BRANCH=$(get_test_branch ${PROJECT_NAME}) && \
	VERSION_FILE=$(get_version_file ${PROJECT_NAME}) && \
	git co ${TEST_BRANCH} && \
	git pull && \
	git merge ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			printf "\033[0;31mERROR:\033[0m Conflict in non-version files!\n"
			return 1
		fi

		printf "\033[0;32mINFO:\033[0m Conflict in version file.\n"
		printf "\033[0;32mINFO:\033[0m Trying to resolve...\n"

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git commit --file .git/MERGE_MSG
	fi && \
	CURRENT_VER=$(git describe) && \
	PROD_VER=$(git describe prod) && \
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
	git submodule update && \
	git push && \
	git t "Release $NEW_VER" ${NEW_VER} && \
	git push --tags && \
	git co ${BRANCH_NAME} && \
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
	git pull
	git merge ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			printf "\033[0;31mERROR:\033[0m Conflict in non-version files!\n"
			return 1
		fi

		printf "\033[0;32mINFO:\033[0m Conflict in version file.\n"
		printf "\033[0;32mINFO:\033[0m Trying to resolve...\n"

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	git pull --rebase origin ${PROD_BRANCH}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			printf "\033[0;31mERROR:\033[0m Conflict in non-version files!\n"
			return 1
		fi

		printf "\033[0;32mINFO:\033[0m Conflict in version file.\n"
		printf "\033[0;32mINFO:\033[0m Trying to resolve...\n"

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git co ${PROD_BRANCH} && \
	git pull && \
	git rebase ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			printf "\033[0;31mERROR:\033[0m Conflict in non-version files!\n"
			return 1
		fi

		printf "\033[0;32mINFO:\033[0m Conflict in version file.\n"
		printf "\033[0;32mINFO:\033[0m Trying to resolve...\n"

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
	git pull && \
	git merge ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			printf "\033[0;31mERROR:\033[0m Conflict in non-version files!\n"
			return 1
		fi

		printf "\033[0;32mINFO:\033[0m Conflict in version file.\n"
		printf "\033[0;32mINFO:\033[0m Trying to resolve...\n"

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git commit --file .git/MERGE_MSG
	fi

	git submodule update && \
	git push && \
	git co ${BRANCH_NAME} && \
	git pull --rebase origin ${PROD_BRANCH}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			printf "\033[0;31mERROR:\033[0m Conflict in non-version files!\n"
			return 1
		fi

		printf "\033[0;32mINFO:\033[0m Conflict in version file.\n"
		printf "\033[0;32mINFO:\033[0m Trying to resolve...\n"

		git checkout --theirs ${VERSION_FILE} && \
		git add ${VERSION_FILE}
		git rebase --continue
	fi

	git co ${PROD_BRANCH} && \
	git pull && \
	git rebase ${BRANCH_NAME}

	if [ ! $? -eq 0 ]; then
		OUTPUT="$(git st | grep UU)"

		if [ "$OUTPUT" != "UU $VERSION_FILE" ]; then
			printf "\033[0;31mERROR:\033[0m Conflict in non-version files!\n"
			return 1
		fi

		printf "\033[0;32mINFO:\033[0m Conflict in version file.\n"
		printf "\033[0;32mINFO:\033[0m Trying to resolve...\n"

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
		REPLACE store_user_order VALUES
			(631224, '0cf54bd01ca0ff829773de3070096222f389fd3d', 1455542832, 1455792111, null, 0, 2310, 2310, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, 0, null, null);
		REPLACE store_user_order_list VALUES
			(1963895, 631224, 15510, 2310, 2310, null, 1, 1455791602, 14830, 37694, 0);
		REPLACE store_user_order_list VALUES
			(1963896, 631224, 101037, 3860, 3860, null, 1, 1455791602, 14830, 85675, -1);
		DELETE FROM store_user_wish where i_id = 134763;
		DELETE FROM store_user_wish_list where i_ref_id = 134763;
		REPLACE zs_ru_etoya.store_user_wish VALUES
			(134763, '80e04502a86ddd9b0e54a5d6d842366b985e78fe', 1455879832, 1455886831, null, 0, 1, 8139, 8139, 0, '', '', '75193c864db229eae82f1dd38dca5e2cffc37a73134763');
		REPLACE zs_ru_etoya.store_user_wish_list VALUES
			(252640, 134763, 92056, 1455886831, 0, 0, 2680, 2680, null, 80951);
		REPLACE store_gift_promo_code VALUES
			(75393, '74FHZT', 'disc_20', 1458310312, 2451934800, 0, 0, 0, 0, '')"

	cd "$HOME/api"
	dredd ${APIB_FILE}
	cd - >/dev/null
}
