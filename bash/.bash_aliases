#@IgnoreInspection BashAddShebang
# Set path to project dir
PROJECT_PATH="$HOME/dev"
WWW_ROOT='/home/web'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	export GREP_OPTIONS='--color=auto'
fi

options='-H -X --file-type --group-directories-first'
# Test ls for available non-standard options
for i in ${options}; do
	command ls ${i} >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		ls_options="$ls_options $i"
	fi
done

alias ll="ls -lh $ls_options"
alias la="ls -Alh $ls_options"
unset ls_options options

alias webon='
	sudo service mysql start && \
	sudo service php5-fpm start && \
	sudo service nginx start && \
	sudo service memcached start && \
	sudo service gearman-job-server start'

alias weboff='
	sudo service mysql stop && \
	sudo service php5-fpm stop && \
	sudo service nginx stop && \
	sudo service memcached stop && \
	sudo service gearman-job-server stop'

alias itvaultupd="
	rsync \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates  \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/./itvault/www/ itvault:$WWW_ROOT"

alias mantisupd="
	rsync \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-after \
		-Ravry $PROJECT_PATH/./mantis/www/ itvault:$WWW_ROOT"

alias nachkiupd="
	rsync \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/./nachki/www/ itvault:$WWW_ROOT"

alias countersupd="
	rsync \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates  \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/./test.alfaservisteplo/www/ itvault:$WWW_ROOT"

alias countersupl='
	ssh itvault "
		DIR_NAME=$(date "+%Y-%m-%d_%H-%M-%S") && \
		cd ~/alfaservisteplo && \
		cp -R ~/test.alfaservisteplo/www/ \$DIR_NAME && \
		ln -shf \$DIR_NAME www"'

alias chatupd="
	rsync \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/./chat.itvault/www/ itvault:$WWW_ROOT"

alias eva="$PROJECT_PATH/eva/build/eva"
alias eva_build_doc='rm -rf ~/dev/eva/documentation && doxygen ~/Progects/eva/src/doxygen.eva.cfg'
alias phpcs_itvault='
	phpcs -s -v --tab-width=4 \
		--report=full \
		--report-file=phpcs_report.txt \
		--standard=PSR1 \
		--encoding=utf-8 \
		--extensions=php,phtml ./'
# Cli task manager
alias t='python ~/.tasks/t.py --task-dir ~/.tasks --list tasks.txt'
# Completed tasks cleanup
alias tc='[ -w ~/.tasks/.tasks.txt.done ] && rm ~/.tasks/.tasks.txt.done'
alias leafpad='leafpad --tab-width=4'
alias c='clear'

# Check available diff options
options='--tabsize=4'
diff_cmd='diff -u'
for i in ${options}; do
	command diff ${i} ~/.dotfiles/bash/.bashrc ~/.dotfiles/bash/.bashrc >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		diff_options="$diff_options $i"
	fi
done
# Use colored diff if available
command -v colordiff >/dev/null 2>&1
if [ $? -eq 0 ]; then diff_cmd='colordiff -u'; fi

alias diff="$diff_cmd $diff_options"
unset diff_cmd diff_options options

alias err='tail -f /var/log/php_errors.log'
alias coverage-report-veles="
	rm -rf $PROJECT_PATH/Veles/coverage-report;
	cd $PROJECT_PATH/Veles && \
	phpunit -c Tests/phpunit.xml --coverage-html coverage-report;
	cd - >/dev/null"

alias coverage-report-zero="
	rm -rf $PROJECT_PATH/zerotech-test/coverage-report;
	cd $PROJECT_PATH/zerotech-test && \
	phpunit -c phpunit.xml --coverage-html coverage-report;
	cd - >/dev/null"

alias phpunit-veles="
	cd $PROJECT_PATH/Veles && \
	phpunit -c Tests/phpunit.xml --exclude-group=apc;
	cd - >/dev/null"
alias git-test='
	BRANCH_NAME=$(git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/") && \
	git co test && \
	git pull && \
	git merge $BRANCH_NAME && \
	git submodule update && \
	git push && \
	git co $BRANCH_NAME && \
	unset BRANCH_NAME'

alias git-prod='
	BRANCH_NAME=$(git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/") && \
	git pull --rebase origin prod && \
	git co prod && \
	git pull && \
	git rebase $BRANCH_NAME && \
	git submodule update && \
	git br -d $BRANCH_NAME && \
	git push && \
	git describe && \
	unset BRANCH_NAME'

alias git-prod-patch='
	BRANCH_NAME=$(git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/") && \
	CURRENT_API_VER=$(git tag | sort -V | tail -n 1) && \
	VERSION_ARRAY=(${CURRENT_API_VER//./ }) && \
	PATCH_VER=$((${VERSION_ARRAY[2]} + 1)) && \
	NEW_API_VER="${VERSION_ARRAY[0]}.${VERSION_ARRAY[1]}.$PATCH_VER" && \
	perl -pi -e "s/current_version = '\''[^'\'']+/current_version = '\''$NEW_API_VER/g" _modules/project/api/application.inc.php && \
	git add _engine/_lib/start.inc.php && \
	git ci "Update API version" && \
	git co test && \
	git pull && \
	git merge $BRANCH_NAME && \
	git submodule update && \
	git push && \
	git co $BRANCH_NAME && \
	git pull --rebase origin prod && \
	git co prod && \
	git pull && \
	git rebase $BRANCH_NAME && \
	git submodule update && \
	git br -d $BRANCH_NAME && \
	git push && \
	git t "Release $NEW_API_VER" $NEW_API_VER && \
	git push --tags && \
	git describe && \
	unset BRANCH_NAME CURRENT_API_VER VERSION_ARRAY PATCH_VER'

alias git-prod-minor='
	BRANCH_NAME=$(git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/") && \
	CURRENT_API_VER=$(git tag | sort -V | tail -n 1) && \
	VERSION_ARRAY=(${CURRENT_API_VER//./ }) && \
	MINOR_VER=$((${VERSION_ARRAY[1]} + 1)) && \
	NEW_API_VER="${VERSION_ARRAY[0]}.$MINOR_VER.0" && \
	perl -pi -e "s/current_version = '\''[^'\'']+/current_version = '\''$NEW_API_VER/g" _modules/project/api/application.inc.php && \
	git add _engine/_lib/start.inc.php && \
	git ci "Update API version" && \
	git co test && \
	git pull && \
	git merge $BRANCH_NAME && \
	git submodule update && \
	git push && \
	git co $BRANCH_NAME && \
	git pull --rebase origin prod && \
	git co prod && \
	git pull && \
	git rebase $BRANCH_NAME && \
	git submodule update && \
	git br -d $BRANCH_NAME && \
	git push && \
	git t "Release $NEW_API_VER" $NEW_API_VER && \
	git push --tags && \
	git describe && \
	unset BRANCH_NAME CURRENT_API_VER VERSION_ARRAY MINOR_VER'

alias coverage-report-api="
	rm -rf $PROJECT_PATH/api-iledebeaute/tests/coverage-report;
	cd $PROJECT_PATH/api-iledebeaute/tests && \
	phpunit -c phpunit-local.xml --coverage-html coverage-report;
	cd - >/dev/null"

alias phpunit-api="
	cd $PROJECT_PATH/api-iledebeaute/tests && \
	phpunit -c phpunit-local.xml
	cd - >/dev/null"

unset PROJECT_PATH WWW_ROOT

alias whatismyip='dig +short myip.opendns.com @resolver1.opendns.com'
alias fix-resolution='xrandr --output LVDS-0 --mode 1920x1080'
