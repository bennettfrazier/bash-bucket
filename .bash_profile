# ----------------------
# TODO - List of tasks in order of priority
# ----------------------
# 1. Rewrite to make it's own script file instead of attaching functions to .bash_profile
# 2. Create Homebrew tap -> https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap.html
# 3. Rewrite docs for easier setup
# 4. Add parameters and help
# 5. Cleanup fallback issues
# 6. Put variables into stored config file
# 7. Adjust script to run via Node (look at create-react-app for reference) -> https://github.com/tj/commander.js

# Bash Bucket Settings
BB_PRINT_PREFIX="🌀 [Bash Bucket]"

# Bitbucket settings
BB_BITBUCKET="bitbucket.org"
BB_BITBUCKET_BRANCHTYPE="branch"
BB_BITBUCKET_DEFAULT_BRANCH="develop"

# GitHub settings
BB_GITHUB="github.com"
BB_GITHUB_BRANCHTYPE="tree"
BB_GITHUB_DEFAULT_BRANCH="master"

function bb__repo() {
    local REPO_PREFIX=""; # repo in use
    local P=""            # original path
    local B=""            # branch
    local PREFIX=""       # prefix
    local SUFFIX=""       # suffix used based on vcs/repo
    local REPO=""         # repo path

    # String prefix
    local gitPrefix="git@"
    local sshPrefix="ssh://"
    local httpPrefix="http://"
    local httpsPrefix="https://"

    # Check for git in directory
    if [[ -d .git ]]; then
        SUFFIX=".git"
        P="$(git config --get remote.origin.url)"

        #if has github.com
        if [ `echo $P | grep -c "$BB_GITHUB" ` -gt 0 ]
        then
            REPO_PREFIX="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                REPO_PREFIX="$BB_BITBUCKET"
            fi
        fi

        REPO="$P" # set repo to path

        # check ssh for git@ vs https and strip
        REPO=${REPO#$sshPrefix}
        REPO=${REPO#$httpPrefix}
        REPO=${REPO#$httpsPrefix}
        REPO=${REPO#$gitPrefix}
        PREFIX="$REPO_PREFIX/"
        PREFIX2="$REPO_PREFIX:" #remove attempt 2

        # strip repo prefix/suffix
        REPO=${REPO#$PREFIX}
        REPO=${REPO#$PREFIX2}
        REPO=${REPO%$SUFFIX}

    # try mecurial TODO fallback
    else
        # parameters
        P="$(hg paths 2>/dev/null )"

        if [ `echo $P | grep -c "$BB_GITHUB" ` -gt 0 ] #if contains
        then
            # if github is contained in path
            REPO_PREFIX="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                REPO_PREFIX="$BB_BITBUCKET"
            fi
        fi

        # trim and remove prefix/suffix
        REPO="$(echo "$P" | sed -e 's|.*\('$REPO_PREFIX'.*\)|\1|')"
        PREFIX="$REPO_PREFIX/"
        PREFIX2="$REPO_PREFIX:" #remove attempt 2
        SUFFIX="/"
        REPO=${REPO#$PREFIX}
        REPO=${REPO#$PREFIX2}
        REPO=${REPO%$SUFFIX}
    fi;

    echo "https://$REPO_PREFIX/$REPO"
}

# returns the branch name dependent upon the current repository type
function bb__branch() {
    # Check for git in directory
    if [[ -d .git ]]; then
        local B="$(git rev-parse --abbrev-ref HEAD)"
    # try mecurial TODO fallback
    else
        local B="$(hg branch 2>/dev/null)"
    fi;
    echo $B
}

# returns the repo prefix dependent upon the current repository type
function bb__repoPrefix() {
    local REPO_PREFIX=""; # repo in use
    local P=""            # original path

    # Check for git in directory
    if [[ -d .git ]]; then
        P="$(git config --get remote.origin.url)"

        if [ `echo $P | grep -c "$BB_GITHUB" ` -gt 0 ] #if contains
        then
            # if github is contained in remote origin path
            REPO_PREFIX="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                REPO_PREFIX="$BB_BITBUCKET"
            fi
        fi

    # try mecurial TODO fallback
    else
        P="$(hg paths 2>/dev/null )"

        #if contains
        if [ `echo $P | grep -c "$BB_GITHUB" ` -gt 0 ]
        then
            # if github is contained in path
            REPO_PREFIX="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                REPO_PREFIX="$BB_BITBUCKET"
            fi
        fi
    fi;

    echo "$REPO_PREFIX"
}


# returns the branch type dependent upon repository type
function bb__branchType() {
    local REPO_PREFIX=$(bb__repoPrefix)

    if [[ "$REPO_PREFIX" == "github.com" ]]; then
        echo "$BB_GITHUB_BRANCHTYPE"
    else
        echo "$BB_BITBUCKET_BRANCHTYPE"
    fi;
}

function bb() {
    local REPO=$(bb__repo)               #result of running bb__repo function
    local B=$(bb__branch)                #result of running bb__branch function
    local BRANCH_TYPE=$(bb__branchType)  #result of running bb__branchType function
    local REPO_PREFIX=$(bb__repoPrefix)  #result of running bb__repoPrefix function

    if [[ "$REPO" == "" ]]; then
        printf "$BB_PRINT_PREFIX Abort: no repository or branch to open\n";
    else
        local LINK="$REPO/$BRANCH_TYPE/$B"
        printf "$BB_PRINT_PREFIX Open Branch\n🌀 SRC  -------> $B\n🌀 REPO -------> $REPO \n";
        [[ -n $LINK ]] && open $LINK || echo "No $REPO_PREFIX path found!"
    fi;
}

function bbsrc() {
    local REPO=$(bb__repo)               #result of running bb__repo function
    local REPO_PREFIX=$(bb__repoPrefix)  #result of running bb__repoPrefix function

    if [[ "$REPO" == "" ]]; then
        printf "$BB_PRINT_PREFIX Abort: no repository or branch to open\n";
    else
        local LINK="$REPO"
        printf "$BB_PRINT_PREFIX Open Source\n🌀 SRC  -------> $B\n🌀 REPO -------> $REPO \n";
        [[ -n $LINK ]] && open $LINK || echo "No $REPO_PREFIX path found!"
    fi;
}

function bbhome() {
    local REPO=$(bb__repo)                  #result of running bb__repo function
    local REPO_PREFIX=$(bb__repoPrefix)     #result of running bb__repoPrefix function

    if [[ "$REPO_PREFIX" == "" ]]; then
        printf "$BB_PRINT_PREFIX Abort: no repository or branch to get commit history (bash-bucket)\n";
    else
        if [[ "$REPO_PREFIX" == "$BB_GITHUB" ]]; then
            local LINK="$REPO"
        elif [[ "$REPO_PREFIX" == "$BB_BITBUCKET" ]]; then
            local BRANCH_TYPE=$(bb__branchType) #returns branch type
            local LINK="$REPO/"
        fi;
        printf "$BB_PRINT_PREFIX Open Home\n🌀 REPO -------> $REPO \n";
        [[ -n $LINK ]] && open $LINK || echo "No $REPO_PREFIX path found!"
    fi;
}


function bbcomm() {
    local REPO_PREFIX=$(bb__repoPrefix)   #result of running bb__repoPrefix function

    if [[ "$REPO_PREFIX" == "" ]]; then
        printf "$BB_PRINT_PREFIX Abort: no repository or branch to get commit history (bash-bucket)\n";
    else
        # Returned function variables
        local REPO=$(bb__repo)
        local B=$(bb__branch)

        if [[ "$REPO_PREFIX" == "$BB_GITHUB" ]]; then
            local LINK="$REPO/commits/$B"
        else
            if [[ "$REPO_PREFIX" == "$BB_BITBUCKET" ]]; then
                local BRANCH_TYPE=$(bb__branchType) #returns branch type
                local LINK="$REPO/commits/$BRANCH_TYPE/$B"
            fi
        fi
        printf "$BB_PRINT_PREFIX Commit History\n🌀 SRC  -------> $B\n🌀 REPO -------> $REPO \n";
        [[ -n $LINK ]] && open $LINK || echo "No $REPO_PREFIX path found!"
    fi;
}

function bbcomp() {
    local DEST="";
    local LINK="";

    # Returned function vars
    local REPO=$(bb__repo)                  #result of running bb__repo function
    local B=$(bb__branch)                   #result of running bb__branch function
    local BRANCH_TYPE=$(bb__branchType)     #result of running bb__branchType function
    local REPO_PREFIX=$(bb__repoPrefix)     #result of running bb__repoPrefix function

    if [[ "$REPO_PREFIX" == "" ]]; then
        printf "$BB_PRINT_PREFIX Abort: no repository or branch to open\n";
    else
        # Check if REPO_PREFIX Github
        if [[ "$REPO_PREFIX" == "$BB_GITHUB" ]]; then

            # Destination branch compare parameter
            if [[ "$1" == "" ]]; then
                DEST="$BB_GITHUB_DEFAULT_BRANCH";
            else
                DEST="$1";
            fi

            # End result: http://github.com/example/repo/compare/DEST...BRANCH
            LINK="$REPO/compare/$DEST...$B"

        else if [[ "$REPO_PREFIX" == "$BB_BITBUCKET" ]]; then
                # Destination branch compare parameter
                if [[ "$1" == "" ]]; then
                    DEST="$BB_BITBUCKET_DEFAULT_BRANCH";
                else
                    DEST="$1";
                fi

                # End result: http://bitbucket.org/example/repo/branch/BRANCH?dest=DEST#diff
                LINK="$REPO/branch/$B?dest=$DEST#diff"
            fi
        fi
        printf "$BB_PRINT_PREFIX Compare Branches\n🌀 SRC  -------> $B \n🌀 DEST -------> $DEST\n🌀 REPO -------> $REPO \n";
        [[ -n $LINK ]] && open $LINK || echo "No $REPO_PREFIX path found!"
    fi;
}

function pr() {
    local REPO_PREFIX="";
    local LINK="";

    # Returned local vars
    local REPO=$(bb__repo)                 #result of running bb__repo function
    local B=$(bb__branch)                 #result of running bb__branch function
    local BRANCH_TYPE=$(bb__branchType)   #result of running bb__branchType function
    local REPO_PREFIX=$(bb__repoPrefix)   #result of running bb__repoPrefix function


    if [[ "$REPO_PREFIX" == "" ]]; then
        printf "$BB_PRINT_PREFIX Abort: no repository or branch to open\n";
    else
        # Check if REPO_PREFIX Github
        if [[ "$REPO_PREFIX" == "$BB_GITHUB" ]]; then

            # Destination branch compare parameter
            if [[ "$1" == "" ]]; then
                DEST="$BB_GITHUB_DEFAULT_BRANCH";
            else
                DEST="$1";
            fi

            # End result: http://github.com/example/repo/compare/DEST...BRANCH
            LINK="$REPO/compare/$DEST...$B"

        else if [[ "$REPO_PREFIX" == "$BB_BITBUCKET" ]]; then
                # Destination branch compare parameter
                if [[ "$1" == "" ]]; then
                    DEST="$BB_BITBUCKET_DEFAULT_BRANCH";
                else
                    DEST="$1";
                fi

                # Bitbucket does not accept a DEST parameter to be passed for PR request
                LINK="$REPO/pull-requests/new?source=$B&t=1"
            fi
        fi
    fi

    if [[ "$REPO" == "" ]]; then
        printf "$BB_PRINT_PREFIX Abort: no repository or branch to create a PR (bash-bucket)\n";
    else
        printf "$BB_PRINT_PREFIX Pull Request\n🌀 SRC  -------> $B \n🌀 DEST -------> $DEST\n🌀 REPO -------> $REPO \n";
        [[ -n $LINK ]] && open $LINK || echo "No $REPO_PREFIX path found!";
    fi;
}
