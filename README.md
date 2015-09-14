# dotfiles

My .files

## Install

Install [GNU stow] utility:
#### Linux Debian:

    $ sudo apt-get install stow

#### OSX:

    $ brew install stow

#### OpenBSD:

    $ pkg_add stow

Clone this repo into ~/.dotfiles folder:

    $ mkdir ~/.dotfiles
    $ cd ~/.dotfiles
    $ git clone https://github.com/nafigator/dotfiles.git .

Then use stow utility to create symlinks:

    $ stow bash
    $ stow git
    $ . ~/.profile

  [GNU stow]: https://www.gnu.org/software/stow
