# bash-bucket 🌀
Bash Bucket is a command line tool to open repositories, branches, and pull requests in the default browswer for both [Bitbucket](http://bitbucket.org/) and [Github](https://github.com/) with either [Mecurial](https://www.mercurial-scm.org/) or [Git](https://git-scm.com/) as the version control system (VCS).

The purpose of bash-bucket is to efficiently open up current branch details through the terminal window:
- `$ bb` - open current local branch
- `$ bbcomm` - open branch commit history
- `$ bbcomp` - open and compare branches (default is `develop`)
- `$ pr` - open a pull request from current local branch

---------

## Installation

To run these commands, simply copy these functions from the .bash_profile file to your home directory `~/`. If you already have a .bash_profile in `~/`, simply copy in in the functions you would like to use.

### 1. Clone to your favorite dev directory, or download zip directly
```sh
$ git clone https://github.com/bennettfrazier/bash-bucket.git
```

### 2. See if .bash_profile exists in home
```sh
$ cd ~/
$ find . -name '.bash_profile'

# If no .bash_profile exists in ./ or ~/, create an empty file
$ touch .bash_profile
```

### 3. Copy/paste .bash_profile
```sh
# Open .bash_profile through text editor and paste in copied functions
$ cd ~/directory/to/cloned-repo/bash-bucket
$ open .bash_profile # bash-bucket file
# ✂️ Copy all text to clipboard
$ open ~/.bash_profile # home file
# 📑 Paste copied text in (if other functions here, leave them too)

# -- OR --  

# Terminal method to copy/paste
# Note: type out commands (copy & paste will overwrite clipboard)
$ cd ~/directory/to/cloned-repo/bash-bucket
$ cat .bash_profile | pbcopy
$ pbpaste > ~/.bash_profile
```
### 4. Load functions into bash terminal
```sh
# Load in functions in the current shell script
$ source ~/.bash_profile

# -- OR --

# Just open a new Terminal window to enable commands (⌘ + T)
```
Boom, now you can use all the **bash-bucket** commands! 💥

All commands are fully explained below ⬇️

---------

## Terminal Functions
### `$ bb`
Open current branch in Bitbucket
``` sh
$ cd directory/to/current-project
$ bb
```
### `$ bbcomm`
Open current branch commit history in browser
``` sh
$ cd directory/to/current-project
$ bbcomm
```
### `$ bbcomp`
Compare current branch as source to a destination branch
``` sh
$ cd directory/to/current-project

# Replace 'destinationBranchName' with branch to compare
$ bbcomp destinationBranchName

# -- OR --

# By default, this function will compare current branch to 'develop'
$ bbcomp
```
### `$ pr`
Opens browser to create a pull request in Bitbucket
``` sh
$ cd directory/to/current-project
$ pr
```

---------

### Credit/inspiration:
- [Open Bitbucket from Bash](http://hgtip.com/tips/advanced/2009-10-08-open-bitbucket-from-bash/) by [Steve Posh](http://stevelosh.com/)
- [An introduction to useful bash aliases and functions](https://www.digitalocean.com/community/tutorials/an-introduction-to-useful-bash-aliases-and-functions) by Justin Ellingwood @ DigitalOcean
