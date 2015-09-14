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

alias ll='ls -hHAl'
alias la='ls -hHAv'
alias l='ls -CF'
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

alias t='python ~/.tasks/t.py --task-dir ~/.tasks --list tasks.txt'
alias leafpad='leafpad --tab-width=4'
alias c='echo -e "\033\0143"'

alias diff='diff --tabsize=4'
alias err='tail -f /var/log/php.err'
alias coverage-report-veles="
	rm -rf $PROJECT_PATH/Veles/coverage-report;
	cd $PROJECT_PATH/Veles && \
	phpunit -c phpunit.xml --coverage-html coverage-report;
	cd - >/dev/null"

alias coverage-report-zero="
	rm -rf $PROJECT_PATH/zerotech-test/coverage-report;
	cd $PROJECT_PATH/zerotech-test && \
	phpunit -c phpunit.xml --coverage-html coverage-report;
	cd - >/dev/null"

alias phpunit-veles="
	cd $PROJECT_PATH/Veles && \
	phpunit -c phpunit.xml --exclude-group=apc;
	cd - >/dev/null"
alias api-test='
	BRANCH_NAME=$(git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/") && \
	git co test && \
	git pull && \
	git merge --ff-only $BRANCH_NAME && \
	git push && \
	git co $BRANCH_NAME'

alias api-prod='
	BRANCH_NAME=$(git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/\1/") && \
	git pull --rebase origin prod && \
	git co prod && \
	git pull && \
	git rebase $BRANCH_NAME && \
	git br -d $BRANCH_NAME && \
	git push && \
	git describe'

unset PROJECT_PATH WWW_ROOT

alias svnd='svn diff | colordiff'
alias bash-reload='unalias -a && . ~/.profile'
