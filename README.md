[![GitHub license][License img]][License src]

# dotfiles

My .files optimized for personal needs
###### WARNING: There is no guarantee that this will work in your environment

## Install

Install [GNU stow] utility:
#### Linux Debian:

    $ sudo apt-get install stow

#### OSX:

    $ brew install stow

#### OpenBSD:

    $ sudo pkg_add stow

Clone this repo into ~/.dotfiles folder:

    $ mkdir ~/.dotfiles
    $ cd ~/.dotfiles
    $ git clone https://github.com/nafigator/dotfiles.git .

Backup your previous dotfiles:

    $ cd && mkdir .dotfiles.bkp
    $ mv .profile .bashrc .bash_aliases .bash_logout .gitconfig .gitignore .dotfiles.bkp

Then use stow utility to create symlinks:

    $ stow bash
    $ stow git
    $ . ~/.profile

  [GNU stow]: https://www.gnu.org/software/stow
  [License img]: https://img.shields.io/badge/license-MIT-brightgreen.svg
  [License src]: https://tldrlegal.com/license/mit-license

#### SSH section workflow:
###### Save config changes

    cd ssh/.ssh
    # gpg --output config.gpg --encrypt --recipient <email> config
    gpg -o config.gpg -e -r <email> config
    git commit && git push

###### Load config changes

    git pull
    cd ssh/.ssh
    # gpg --output config --decrypt config.gpg
    gpg -o config -d config.gpg

#### MC section workflow:
###### Ignore local ini changes

    git update-index --assume-unchanged mc/.config/mc/ini
