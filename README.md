# bash-bucket cli 🌀
Bash Bucket is a command line interface to open repositories, branches, and pull requests in the default browswer for both [Bitbucket](http://bitbucket.org/) and [Github](https://github.com/) with either [Mecurial](https://www.mercurial-scm.org/) or [Git](https://git-scm.com/) as the version control system (VCS).

<br>
<div align="center">
<img src='https://raw.githubusercontent.com/bennettfrazier/bash-bucket/master/media/bash-bucket.gif'>
<br>
</div>

The purpose of bash-bucket is to efficiently open up current branch details through the terminal window:
- `$ bb` - open repo in browser
- `$ bb branch` - open current branch
- `$ bb commits` - open branch commit history
- `$ bb compare [branch]` - open and compare current branch to optional argument
- `$ bb issues` - go to issues in browser
- `$ bb info` - get branch and repo information about current directory
- `$ bb pr` - open a pull request from current branch
- `$ bb repo` - open repo in browser

---------

## Installation
```sh
$ npm i bash-bucket -g # installs as global CLI
```


Boom, now you can use all the **bash-bucket** commands! 💥

All commands are fully explained below ⬇️

---------

## Commands


### `branch`
Open current branch in browser
``` sh
$ cd directory/to/current-project
$ bb branch [branch] # open specific branch as optional parameter rather than current
```

### `commits`
Open current branch commit history in browser
``` sh
$ cd directory/to/current-project
$ bb commits
```

### `compare`
Compare current branch as source to a destination branch
``` sh
$ cd directory/to/current-project

# Replace 'branch' with branch you want to compare current branch to
$ bb compare [branch]

# -- OR --

# By default, this function will compare current branch to 'develop'
$ bb compare
```

### `info`
Get branch/repo information returned in terminal window
``` sh
$ cd directory/to/current-project
$ bb info
```

### `issues`
Opens browser to current issues
``` sh
$ cd directory/to/current-project
$ bb issues
```

### `pr`
Opens browser to create a pull request in Bitbucket
``` sh
$ cd directory/to/current-project
$ bb pr
```

### `repo`
Open current branch in Bitbucket
``` sh
$ cd directory/to/current-project
$ bb

# -- OR --

$ bb repo
```

---------

### Credit/inspiration:
- [Open Bitbucket from Bash](http://hgtip.com/tips/advanced/2009-10-08-open-bitbucket-from-bash/) by [Steve Posh](http://stevelosh.com/)
- [An introduction to useful bash aliases and functions](https://www.digitalocean.com/community/tutorials/an-introduction-to-useful-bash-aliases-and-functions) by Justin Ellingwood @ DigitalOcean
- [gh-home by Sindre Sorhus](https://github.com/sindresorhus/gh-home/)
