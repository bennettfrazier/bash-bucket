#!/usr/bin/env node
'use strict';

// ----------------------
// TODO - List of tasks in order of priority
// ----------------------
// 1. Create Homebrew tap -> https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap.html
// 2. Rewrite docs for easier setup
// 3. Add more parameters and help
// 4. Cleanup fallback issues
// 5. Put variables into stored config file

// require and string constants
const meow = require('meow'),
      opn = require('opn'),
      execa = require('execa'),
      chalk = require('chalk'),
      bbPrefix = '  🌀  ',
      Bitbucket = 'bitbucket',
      Github = 'github',
      Git = 'git',
      Hg = 'hg',
      bb = require('.');

// cli constants
const help = require('./help.js'),
      cli = meow(help.CONSOLE),
      command = cli.input[0],
      option1 = cli.input[1],
      option2 = cli.input[2];

// vars
var repo = '',
    repoPrefix = '',
    repoType = '',
    repoUrl = '',
    branchType = '',
    branch = '',
    url = '',
    printOpenUrlConsole = true;


let runBB = () => {
    try {
        tryGit();

    } catch(error) {
        tryHg();

        // TODO error catching nested?
    }

    // cli steps to get repo/paths/urls
    determineRepoPrefix();
    cleanupRepoString();
    setRepoDomain(); // validate this works in all cases

    // run through cli commands
    if (command) {
        switch (command) {
            case 'branch':
                setUrlForBranch();
                break;
            case 'commits':
                setUrlForCommits();
                break;
            case 'compare':
                setUrlForCompare();
                break;
            case 'issues':
                setUrlForIssues();
                break;
            case 'pr':
                setUrlForPR();
                break;
            case 'repo':
                url = `${repoUrl}${repo}`;
                break;
            default:
        }

        // TODO cleanup --> open url except on info
        if (command == 'info' || command == 'i') {
            url = `${repoUrl}${repo}`;
            printOpenUrlConsole = false;
        } else {
            opn(url, {wait: false});
        }

    } else {
        url = `${repoUrl}${repo}`;
        opn(url, {wait: false});
    }

    logInfo();
}

//-------------
// methods
//-------------

let tryGit = () => {
    // try git
    const gitRepo = execa.sync(Git, ['config', '--get', 'remote.origin.url']).stdout;

    // strip repo path
    repo = gitRepo.toLowerCase();
    repo = repo.replace('.git','');
    repoType = Git;
}

let tryHg = () => {
    // try hg
    const hgRepo = execa.sync(Hg, ['paths']).stdout;

    // strip repo path
    repo = hgRepo.toLowerCase();
    repoType = Hg;
}


let determineRepoPrefix = () => {
    if (repo.includes(Bitbucket + '.org')) {
        repo = repo.replace(Bitbucket,'');
        repoPrefix = Bitbucket;
    } else if (repo.includes(Github) + '.com') {
        repo = repo.replace(Github,'');
        repoPrefix = Github;
    }
}

let cleanupRepoString = () => {
    // remove common strings to get repo
    repo = repo.substring(repo.indexOf("@") + 1); //rm anything before @
    repo = repo.replace('ssh://','');
    repo = repo.replace('https://','');
    repo = repo.replace('.org/','');
    repo = repo.replace('.org:','');
    repo = repo.replace('.com/','');
    repo = repo.replace('.com:','');
}


let logInfo = () => {
    if (command && branch) {
        console.log('\n' + chalk.yellow.bold('[Bash Bucket]') + ' ' + chalk.yellow.bgBlue.bold(` ${command} > `) + chalk.blue.bgYellow.bold(` ${branch} `) + '\n');
    } else if (command) {
        console.log('\n' + chalk.yellow.bold('[Bash Bucket]') + ' ' + chalk.yellow.bgBlue.bold(` ${command} `) + '\n');
    } else {
        console.log('\n' + chalk.yellow.bold('[Bash Bucket]') + '\n');
    }
    console.log(bbPrefix + 'repo:          ' + chalk.blue.bold.underline(repo));
    console.log(bbPrefix + 'repo type:     ' + chalk.blue.bold.underline(repoType));
    console.log(bbPrefix + 'repo prefix:   ' + chalk.blue.bold.underline(repoPrefix));
    if (branch) {
        console.log(bbPrefix + 'branch:        ' + chalk.blue.bold.underline(branch));
    }
    if (printOpenUrlConsole) {
        console.log(bbPrefix + 'opening url -> ' + chalk.blue.bold.underline(url));
    } else {
        console.log(bbPrefix + 'repo home ->   ' + chalk.blue.bold.underline(url));
    }
    console.log();
}


//-------------
// getters
//-------------

let getBranch = () => {
    // get branch
    if (repoType == 'git') {
        const gitBranch = execa.sync('git', ['rev-parse', '--abbrev-ref', 'HEAD']).stdout;
        branch = gitBranch;
    } else if (repoType == 'hg') {
        const hgBranch = execa.sync('hg', ['branch']).stdout;
        branch = hgBranch;
    }

    // get branch type
    if (repoPrefix == Github) {
        branchType = 'tree';
    } else if (repoPrefix == Bitbucket) {
        branchType = 'branch';
    }
    return branch;
}


//-------------
// setters
//-------------

let setRepoDomain = () => {
    if (repoPrefix == Github) {
        repoUrl = ('https://' + Github + '.com/');
    } else if (repoPrefix == Bitbucket) {
        repoUrl = ('https://' + Bitbucket + '.org/');
    }
}

let setUrlForCompare = () => {
    branch = getBranch();

    if (option1) {
        if (repoPrefix == Github) {
            url =  `${repoUrl}${repo}/compare/${branch}...${option1}`;
        } else if (repoPrefix == Bitbucket) {
            url = `${repoUrl}${repo}/${branchType}/${branch}?dest=${option1}`;
        }
    } else {
        if (repoPrefix == Github) {
            url =  `${repoUrl}${repo}/compare/${branch}...develop`;
        } else if (repoPrefix == Bitbucket) {
            url = `${repoUrl}${repo}/${branchType}/${branch}?dest=develop`;
        }
    }
}
let setUrlForCommits = () => {
    branch = getBranch();
    if (repoPrefix == Github) {
        url =  `${repoUrl}${repo}/commits/${branch}`;
    } else if (repoPrefix == Bitbucket) {
        url = `${repoUrl}${repo}/commits/${branchType}/${branch}`;
    }
}

let setUrlForBranch = () => {
    branch = getBranch();
    url = `${repoUrl}${repo}/${branchType}/${branch}`;
}

let setUrlForPR = () => {
    if (repoPrefix == Github) {
        url =  `${repoUrl}${repo}/pulls`;
    } else if (repoPrefix == Bitbucket) {
        branch = getBranch();
        url = `${repoUrl}${repo}/pull-requests/new?source=${branch}&t=1`;
    }
}

let setUrlForIssues = () => {
    url =  `${repoUrl}${repo}/issues`;
}

runBB(); // runs bash bucket cli
