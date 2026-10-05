[![GitHub license][License img]][License src] [![Conventional Commits][Conventional commits badge]][Conventional commits src]

# dotfiles

My .files optimized for personal needs
###### WARNING: There is no guarantee that this will work in your environment

## Install

Install [GNU stow] utility:
#### Linux Debian:

```shell
sudo apt-get install stow
```

#### OSX:

```shell
brew install stow
```

#### OpenBSD:

```shell
sudo pkg_add stow
```

Clone this repo into ~/.dotfiles folder:

```shell
mkdir ~/.dotfiles
cd ~/.dotfiles
git clone https://github.com/nafigator/dotfiles.git .
```

Backup your previous dotfiles:

```shell
cd && mkdir .dotfiles.bkp
mv .profile .bashrc .bash_aliases .bash_logout .gitconfig .gitignore .dotfiles.bkp
```

Then use stow utility to create symlinks:

```shell
stow bash
stow git
. ~/.profile
```

#### SSH section workflow:
###### Save config changes

```shell
cd ssh/.ssh
# gpg --output config.gpg --encrypt --recipient <email> config
gpg -o config.gpg -e -r <email> config
git commit && git push
```

###### Load config changes

```shell
git pull
cd ssh/.ssh
# gpg --output config --decrypt config.gpg
gpg -o config -d config.gpg
```

#### MC section workflow:
###### Ignore local ini changes

```shell
git update-index --assume-unchanged mc/.config/mc/ini
```

[GNU stow]: https://www.gnu.org/software/stow
[License img]: https://img.shields.io/github/license/nafigator/dotfiles?color=teal
[License src]: https://tldrlegal.com/license/mit-license
[Conventional commits src]: https://conventionalcommits.org
[Conventional commits badge]: https://img.shields.io/badge/Conventional%20Commits-1.0.0-teal.svg
