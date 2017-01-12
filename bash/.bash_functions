#!/usr/bin/env bash

# Screen cleanup
c() {
	printf "\033c";
	[[ "$(uname -s)" == "Linux" ]] && env TERM=linux setterm -regtabs 4
}

# Function for error
err() {
	printf "[$(date --rfc-3339=seconds)]: \033[0;31mERROR:\033[0m $@\n" >&2
}

# Function for informational messages
inform() {
	printf "[$(date --rfc-3339=seconds)]: \033[0;32mINFO:\033[0m $@\n"
}

# Function for warning messages
warn() {
	printf "[$(date --rfc-3339=seconds)]: \033[0;33mWARNING:\033[0m $@\n" >&2
}

# Function for debug messages
debug() {
	[ ! -z ${DEBUG} ] && printf "[$(date --rfc-3339=seconds)]: \033[0;32mDEBUG:\033[0m $@\n"
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
		err "Not found required parameters!"
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
		err "Not found required parameters!"
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
		err "Not found required parameters!"
		return 1
	fi

	case $1 in
		Veles) echo 'README.md' ;;
		api-iledebeaute) echo '_modules/project/api/application.inc.php' ;;
		api-iledebeaute-test) echo '_modules/project/api/application.inc.php' ;;
		*) echo 'version.ini' ;;
	esac
}

# Show version regular expression
get_version_regex() {
	if [ -z $1 ] || [ -z $2 ]; then
		err "Not found required parameters!"
		return 1
	fi

	case $1 in
		Veles) echo "s/badge\/release-[^-]+/badge\/release-$2/g" ;;
		api-iledebeaute) echo "s/current_version = '[^']+/current_version = '$2/g" ;;
		api-iledebeaute-test) echo "s/current_version = '[^']+/current_version = '$2/g" ;;
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
	unset -f c err inform warn parse_git_branch parse_project_name get_test_branch get_prod_branch get_version_file get_version_regex digga bash-reload calc api-get api-post api-put api-del api-test-get api-test-post api-test-put api-test-del git-test git-prod git-prod-patch git-prod-minor

	if [ -f ~/.xsessionrc ]; then
		. ~/.xsessionrc
	elif [ -f ~/.bashrc ]; then
		. ~/.bashrc
	fi

	printf "\033[0;33mBash reloading ... [\033[0;32mOK\033[0;33m]\033[0m\n"
}

# Calculator
calc() {
	echo "$*" | bc -l;
}

# Aliases for testing API with curl
api-get() {
	if [ -z $1 ]; then
		err "Not found required parameters!"
		return 1
	fi
	if [ -z $2 ]; then
		local options="http://json.nafigator.babysfera.ru$1"
		#local options="https://json.babysfera.ru$1"
	else
		local options="--data-binary $1 http://json.nafigator.babysfera.ru$2"
		#local options="--data-binary $1 https://json.babysfera.ru$2"
	fi

	c && \
	curl -i \
		--request GET \
		--cookie "XDEBUG_SESSION=1" \
		--header "Authorization: b98cc897bb3a4c9dc865b0caef0eab0c36f62820f408a8ece4bebc9e972d1241" \
		--user-agent "Curl v.7.40.0" \
		"$options"
	echo
}

api-post() {
	if [ -z $1 ] || [ -z $2 ]; then
		err "Not found required parameters!"
		return 1
	fi
	c && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--header "Authorization: b98cc897bb3a4c9dc865b0caef0eab0c36f62820f408a8ece4bebc9e972d1241" \
		--user-agent "Curl v.7.40.0" \
		--data "$1" \
		http://json.nafigator.babysfera.ru$2
	echo
}

api-put() {
	if [ -z $1 ] || [ -z $2 ]; then
		err "Not found required parameters!"
		return 1
	fi
	c && \
	curl -i \
		-X PUT \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0; UTC+3) API/1.0" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.lo$2
	echo
}

api-del() {
	if [ -z $1 ]; then
		err "Not found required parameters!"
		return 1
	fi
	if [ -z $2 ]; then
		local options="http://api.lo$1"
	else
		local options="--data-binary $1 http://api.lo$2"
	fi

	c && \
	curl -i \
		--request DELETE \
		--cookie "XDEBUG_SESSION=1" \
		--user "1:1111111111111111111111111111111111111111" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0; UTC+3) API/1.0" \
		"$options"
	echo
}

# Aliases for testing API with curl
api-test-get() {
	if [ -z $1 ]; then
		err "Not found required parameters!"
		return 1
	fi
	if [ -z $2 ]; then
		local options="http://api.etoya.ru.zerostudio.ru$1"
	else
		local options="--data-binary $1 http://api.lo$2"
	fi

	c && \
	curl -i \
		--request GET \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0; UTC+3) API/1.0" \
		"$options"
	echo
}

api-test-post() {
	if [ -z $1 ] || [ -z $2 ]; then
		err "Not found required parameters!"
		return 1
	fi
	c && \
	curl -i \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0; UTC+3) API/1.0" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.etoya.ru.zerostudio.ru$2
	echo
}

api-test-put() {
	if [ -z $1 ] || [ -z $2 ]; then
		err "Not found required parameters!"
		return 1
	fi
	c && \
	curl -i \
		-X PUT \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0; UTC+3) API/1.0" \
		--header "Content-Type: application/json" \
		--data-binary "$1" \
		http://api.etoya.ru.zerostudio.ru$2
	echo
}

api-test-del() {
	if [ -z $1 ]; then
		err "Not found required parameters!"
		return 1
	fi
	if [ -z $2 ]; then
		local options="http://api.etoya.ru.zerostudio.ru$1"
	else
		local options="--data-binary $1 http://api.lo$2"
	fi

	c && \
	curl -i \
		--request DELETE \
		--cookie "XDEBUG_SESSION=1" \
		--user "745:4fc4e63d0e952ee76bcf73b2d4cad0edc66f50f8" \
		--user-agent "IledebeauteMobileApp (apiary.io/1A; apib-file/1.0; UTC+3) API/1.0" \
		"$options"
	echo
}

git-test() {
	local branch_name="$(parse_git_branch)" && \
	local project_name="$(parse_project_name)" && \
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

	if [ "$check_ver" != "$prod_ver" ]; then
		local version_array=(${prod_ver//./ })
		local patch_array=(${version_array[2]//-/ })
	fi

	if [ "${patch_array[1]}" = "dev" ]; then
		local dev_ver=$((${patch_array[2]} + ${patch_array[3]} + 1))
	else
		local dev_ver=$((${patch_array[1]} + 1))
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
	local branch_name="$(parse_git_branch)" && \
	local project_name="$(parse_project_name)" && \
	if [ -z "$project_name" ] || [ -z "$branch_name" ]; then
		return 1
	else
		local prod_branch="$(get_prod_branch "$project_name")"
	fi && \
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

api-dredd() {
	local apib_file="$HOME/api/tests/iledebeaute.apib"
	local sql_default_file="$HOME/api/tests/default.sql"
	local sql_user_file="$HOME/api/tests/default-user.sql"
#	local sql_mail_file="$HOME/api/tests/default-mail.sql"

	if [ ! -r "$apib_file" ]; then
		err "Not found apib-file!"
		return 1
	fi

	if [ ! -r "$sql_default_file" ]; then
		err "Not found $sql_default_file!"
		return 1
	fi

	if [ ! -r "$sql_user_file" ]; then
		err "Not found $sql_user_file!"
		return 1
	fi

#	if [ ! -r "$sql_mail_file" ]; then
#		err "Not found $sql_mail_file!"
#		return 1
#	fi

	mysql -uroot zs_ru_etoya -s < "$sql_default_file"

	if [ ! $? -eq 0 ]; then
		err "$sql_default_file failure!"
		return 1
	fi

	mysql -uroot zs_ru_etoya -s < "$sql_user_file"

	if [ ! $? -eq 0 ]; then
		err "$sql_user_file failure!"
		return 1
	fi

#	mysql -uroot zs_ru_etoya_mail -s < "$SQL_MAIL_FILE"
#
#	if [ ! $? -eq 0 ]; then
#		err "SQL_MAIL_FILE failure!"
#		return 1
#	fi

	cd "$HOME/api"
	dredd "$apib_file"

	cd - >/dev/null
}
