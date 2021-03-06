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

options='-H -v --file-type --group-directories-first'
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
		--filter='P /public/uploads' \
		--delete \
		--delete-excluded \
		--delete-after \
		-uRa $PROJECT_PATH/itvault/www/./ itvault:$WWW_ROOT/www.itvault.info/
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

# Cli task manager
alias t='python ~/.tasks/t.py --task-dir ~/.tasks --list tasks.txt'
# Completed tasks cleanup
alias tc='[ -w ~/.tasks/.tasks.txt.done ] && rm ~/.tasks/.tasks.txt.done'
alias leafpad='leafpad --tab-width=4'

# Check available diff options
options='--tabsize=4 --color=always'
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
	if [ -d /tmp/veles/coverage-report ]; then
		rm -rf /tmp/veles/coverage-report;
	fi
	mkdir -p /tmp/veles/coverage-report
	cd $PROJECT_PATH/Veles && \
	phpunit -c Tests/phpunit.xml --coverage-html /tmp/veles/coverage-report;
	cd - >/dev/null"

alias phpunit-veles="
	cd $PROJECT_PATH/Veles && \
	phpunit -c Tests/phpunit.xml --exclude-group=apc;
	cd - >/dev/null"

alias phpcs-veles='
	phpcs -p --tab-width=4 \
		--encoding=utf-8 \
		--standard=phpcs.xml \
		--ignore=Tests,vendor,coverage-report,.idea \
		--colors ./'

alias coverage-report-ingos="
	if [ -d $HOME/ingos/coverage-report ]; then
		rm -rf $HOME/ingos/coverage-report;
	fi
	mkdir -p $HOME/ingos/coverage-report
	cd $HOME/ingos && \
	docker-compose exec php vendor/bin/phpunit --testsuite unit --coverage-html coverage-report && \
	cd - >/dev/null"

alias phpunit-ingos="
	cd $HOME/ingos && \
	docker-compose exec php vendor/bin/phpunit --testsuite unit;
	cd - >/dev/null"

unset PROJECT_PATH WWW_ROOT

alias whatismyip='dig +short myip.opendns.com @resolver1.opendns.com'
