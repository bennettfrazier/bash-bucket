# bash-bucket
Bash Bucket is a .bash_profile function set to easily open repositories, branches, and pull requests for [Mecurial](https://www.mercurial-scm.org/) and [Git](https://git-scm.com/) in the browser, all via the command line.

The purpose of bash-bucket is to efficiently open up Bitbucket to:
- open current local branch `$ bb`
- open branch commit history `$ bbcomm`
- open and compare branches `$ bbcomp`
- open a pull request from current local branch `$ pr`


## Installation

To run these commands, simply copy these functions from the .bash_profile file to your home directory `~/`. If you already have a .bash_profile in `~/`, simply copy in in the functions you would like to use.

```sh
# See if .bash_profile exists in home
$ cd ~/ | find . -name '.bash_profile'

# If no .bash_profile exists in ./ or ~/, create an empty file
$ touch .bash_profile

# Clone to your favorite dev directory, or download zip directly
$ git clone https://github.com/bennettfrazier/bash-bucket.git


# Open home .bash_profile in text editor to copy/paste in home ~/.bash_profile
$ cd ~/directory/to/bash-bucket
$ open /.bash_profile
# Copy all text to clipboard

# Open home .bash_profile and paste in copied functions
$ open ~/.bash_profile

# -- OR --

# Terminal copy/paste method
# Note: type commands out, copying & pasting will overwrite clipboard
$ cd ~/directory/to/bash-bucket
$ cat .bash_profile | pbcopy
$ pbpaste > ~/.bash_profile
```

To run any of the functions from the updated `.bash_profile`, open a new window, or:
```sh
# Load in functions in the current shell script
$ source ~/.bash_profile
```


## bash-bucket functions:
#### Open current branch in Bitbucket
``` sh
$ cd directory/to/current-project
$ bb
```

#### Open current branch commit history in browser
``` sh
$ cd directory/to/current-project
$ bbcomm
```

#### Compare current branch as source to a destination branch
``` sh
$ cd directory/to/current-project

# Replace 'destinationBranchName' with branch to compare
$ bbcomp destinationBranchName

# -- OR --

# By default, this function will compare current branch to 'develop'
$ bbcomp
# Compare in browser: [current-branch]
```

#### Opens browser to create a pull request in Bitbucket
``` sh
$ cd directory/to/current-project
$ pr
# PR for branch: [current-branch]
```


### Credit/inspiration:
- [Open Bitbucket from Bash](http://hgtip.com/tips/advanced/2009-10-08-open-Bitbucket-from-bash/) by [Steve Posh](http://stevelosh.com/)
- [An introduction to useful bash aliases and functions](https://www.digitalocean.com/community/tutorials/an-introduction-to-useful-bash-aliases-and-functions) by Justin Ellingwood @ DigitalOcean
