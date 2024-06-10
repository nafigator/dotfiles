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
		--filter='P /project/constants.php' \
		--delete \
		--delete-excluded \
		--delete-after \
		-uRa $PROJECT_PATH/itvault/www/./ itvault:$WWW_ROOT/www.itvault.info/
	ssh -tq itvault \"php $WWW_ROOT/www.itvault.info/tools/unset-routes-cache.php;
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
		-uRav $PROJECT_PATH/mantis/www/./ itvault:$WWW_ROOT/mantis.itvault.info"

alias phpcs-veles='
	phpcs -p --tab-width=4 \
		--encoding=utf-8 \
		--standard=phpcs.xml \
		--ignore=Tests,vendor,coverage-report,.idea \
		--colors ./'

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

unset PROJECT_PATH WWW_ROOT

alias whatismyip='dig +short myip.opendns.com @resolver1.opendns.com'
# Restore resolution
alias rr='xrandr --output HDMI-A-0 --primary --mode 1920x1080 --scale 1x1 --panning 0x0'
alias composer='docker run --user $(id -u):$(id -g) \
	--volume $(pwd):/var/www/html \
	--volume $HOME/.ssh/known_hosts:/etc/ssh/ssh_known_hosts:ro \
	--volume $HOME/.cache/composer:/var/www/.composer/cache \
	--volume /etc/passwd:/etc/passwd:ro \
	--volume /etc/group:/etc/group:ro \
	--volume $SSH_AUTH_SOCK:/ssh-auth.sock \
	--env SSH_AUTH_SOCK=/ssh-auth.sock \
	--env HOME=/var/www \
	--rm -ti nafigat0r/composer:2.4.4'

alias itu='ssh itvault ''uptime'''
alias itr='ssh itvault ''tmux capture-pane -pt rtorrent'''
# Unload Unneeded Services
alias uus='service speech-dispatcher stop; service openvpn stop; service vipnetclient stop; service vboxweb-service stop; service vboxdrv stop; service  vboxballoonctrl-service stop; service tor stop; service bluetooth stop; service cups-browsed stop; service cups stop; service docker stop; service pcscd stop;'
# Start Unneeded Services
alias sus='service speech-dispatcher start; service openvpn start; service vipnetclient start; service vboxweb-service start; service vboxdrv start; service  vboxballoonctrl-service start; service tor start; service bluetooth start; service cups-browsed start; service cups start; service docker start; service pcscd start;'
# Rsync with progress
alias psync='rsync -avPh --skip-compress=gz/jpg/mp[34]/7z/bz2/ba2/bsa/avi/esm/mkv/mpg/pdf --info=progress2 --info=name0 --no-inc-recursive'
