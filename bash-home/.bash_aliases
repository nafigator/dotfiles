#@IgnoreInspection BashAddShebang
# Set path to project dir
PROJECT_PATH="$HOME/dev"
WWW_ROOT='/var/www/vhosts'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
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

alias itvaultupd="
	rsync \
		--rsync-path='doas -u www rsync' \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates  \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-excluded \
		--delete-after \
		-Ravry $PROJECT_PATH/itvault/www/./ itvault:$WWW_ROOT/www.itvault.info/
	ssh itvault \"php $WWW_ROOT/www.itvault.info/tools/unset-routes-cache.php;
	cd $WWW_ROOT/www.itvault.info; tools/phinx migrate -e production\""

alias mantisupd="
	rsync \
		--rsync-path='doas -u www rsync' \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-after \
		-Ravry $PROJECT_PATH/mantis/www/./ itvault:$WWW_ROOT/mantis.itvault.info"

alias ishopupd="
	rsync \
		--rsync-path='doas -u www rsync' \
		--partial \
		--partial-dir=.rsync-partial/ \
		--copy-unsafe-links \
		--delay-updates \
		--exclude-from=.rsync-exclude \
		--delete \
		--delete-after \
		-Ravry $PROJECT_PATH/ishop/./ itvault:$WWW_ROOT/ishop.itvault.info"

alias phpcs-veles='
	phpcs -s -v --tab-width=4 \
		--encoding=utf-8 \
		--standard=phpcs.xml \
		--ignore=Tests,vendor,coverage-report \
		--colors ./'

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
