#@IgnoreInspection BashAddShebang
# Set path to project dir
PROJECT_PATH="$HOME/dev"
WWW_ROOT='/var/www'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
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
		--rsync-path='sudo -u www rsync' \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates  \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/itvault/www/./ itvault:$WWW_ROOT/itvault/"

alias articsupd="
	rsync \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates  \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/./artics-test/ itvault:$WWW_ROOT"

alias mantisupd="
	rsync \
		--rsync-path='sudo -u www rsync' \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-after \
		-Ravry $PROJECT_PATH/mantis/www/./ itvault:$WWW_ROOT/mantis/"

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
		--rsync-path='sudo -u www rsync' \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates  \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/test.alfaservisteplo/www/./ itvault:$WWW_ROOT/test.alfaservisteplo/"

alias countersupl='
	ssh itvault "
		DIR_NAME=$(date "+%Y-%m-%d_%H-%M-%S") && \
		cd $WWW_ROOT/alfaservisteplo/ && \
		cp -R $WWW_ROOT/test.alfaservisteplo/ \$DIR_NAME && \
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