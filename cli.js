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
      Hg = 'hg';

// cli constants
const cli = meow(`
    Usage: bb [command] [options]

    Options:
      --help, -h
      --v, -v

    Commands:

      branch [branch]   go to branch
      commits           go to commits on repo
      compare [branch]  go to compare in browser
      info              get branch and repo information
      issues            go to issues in browser
      pr                go to pr page for branch
      repo              go to repo homepage
`,    { alias: {  h: 'help', v: 'version'}}),
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
    branchToLog = '',
    commandName = '',
    url = '',
    preventOpenUrl = false,
    isValidCommand = false,
    isValidRepo = false;


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
        // TODO: clean up alternate way to check if valid
        if (   command == 'branch' || command == 'b'
        || command == 'commits' || command == 'comm'
        || command == 'compare' || command == 'comp'
        || command == 'issues' || command == 'is'
        || command == 'pr' || command == 'p'
        || command == 'repo' || command == 'r'
        || command == 'info' || command == 'in' ) {
            isValidCommand = true;
        }

        // checks list of commands to set url
        if (command == 'branch' || command == 'b') {
            commandName = 'branch';
            setUrlForBranch();
        } else if (command == 'commits' || command == 'comm') {
            commandName = 'commits';
            setUrlForCommits();
        } else if (command == 'compare' || command == 'comp') {
            commandName = 'compare';
            setUrlForCompare();
        } else if (command == 'issues' || command == 'is') {
            commandName = 'issues';
            setUrlForIssues();
        } else if (command == 'pr' || command == 'p') {
            commandName = 'pull request';
            setUrlForPR();
        } else if (command == 'info' || command == 'in') {
            commandName = 'information';
            url = `${repoUrl}${repo}`;
            preventOpenUrl = true;
        } else {
            // help fallback
            cli.showHelp([2]);
        }

        openRepoInBrowserIfValid();

    } else {
        // defaults to `bb repo`
        commandName = 'repository';
        url = `${repoUrl}${repo}`;
        isValidCommand = true;
        openRepoInBrowserIfValid();
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

let openRepoInBrowserIfValid = () => {
    isValidRepo = checkIsValidRepo();

    if (isValidRepo && isValidCommand && !preventOpenUrl) {
        // delay open browser 0.3sec to see output before browser takes over
        setTimeout(function(){
            opn(url, {wait: false});
        },300);
    }
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
    if (command && branchToLog) {
        console.log('\n' + chalk.yellow.bold('[Bash Bucket]') + ' ' + chalk.yellow.bgBlue.bold(` ${commandName} > `) + chalk.blue.bgYellow.bold(` ${branchToLog} `) + '\n');
    } else if (command) {
        console.log('\n' + chalk.yellow.bold('[Bash Bucket]') + ' ' + chalk.yellow.bgBlue.bold(` ${commandName} `) + '\n');
    } else {
        console.log('\n' + chalk.yellow.bold('[Bash Bucket]') + '\n');
    }

    if (isValidRepo && isValidCommand) {
        console.log(bbPrefix + 'repo:          ' + chalk.blue.bold.underline(repo));
        console.log(bbPrefix + 'repo type:     ' + chalk.blue.bold.underline(repoType));
        console.log(bbPrefix + 'repo prefix:   ' + chalk.blue.bold.underline(repoPrefix));
        if (branch) {
            console.log(bbPrefix + 'branch:        ' + chalk.blue.bold.underline(branch));
        }
        if (preventOpenUrl) {
            console.log(bbPrefix + 'repo home ->   ' + chalk.blue.bold.underline(url));
        } else {
            console.log(bbPrefix + 'opening url -> ' + chalk.blue.bold.underline(url));
        }
    } else if (!isValidCommand) {
        console.log(bbPrefix + 'Not a valid command, see `bb --help` for options.');
    } else {
        console.log(bbPrefix + 'No repository found for this directory -> ', chalk.blue.bold.underline(process.cwd()));
    }
    console.log();
}


//-------------
// getters
//-------------

let getBranch = () => {
    // get branch
    if (repoType == Git) {
        const gitBranch = execa.sync('git', ['rev-parse', '--abbrev-ref', 'HEAD']).stdout;
        branch = gitBranch;
    } else if (repoType == Hg) {
        const hgBranch = execa.sync('hg', ['branch']).stdout;
        branch = hgBranch;
    }

    // get branch type
    if (repoPrefix == Github) {
        branchType = 'tree';
    } else if (repoPrefix == Bitbucket) {
        branchType = 'branch';
    }
    branchToLog = branch;
    return branch;
}

let checkIsValidRepo = () => {
    if (repo) {
        return true;
    }
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
    url = `${repoUrl}${repo}/${branchType}/`;

    if (option1) {
        branchToLog = option1;
        url += `${option1}`;
    } else {
        url += `${branch}`;
    }
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
