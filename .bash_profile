# ----------------------
# TODO - List of tasks in order of priority
# ----------------------
# 1. Rewrite to make it's own script file instead of attaching functions to .bash_profile
# 2. Create Homebrew tap -> https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap.html
# 3. Rewrite docs for easier setup
# 4. Add parameters and help
# 5. Put variables into stored config file
# 6. Adjust script to run via Node (look at create-react-app for reference) -> https://github.com/tj/commander.js

# BB VCS global variables
BB_BITBUCKET="bitbucket.org"
BB_GITHUB="github.com"

# Default branch to compare/pr
BB_DEFAULT_GITHUB="master"
BB_DEFAULT_BITBUCKET="develop"

function bb__repo() {
    local VCS="";          # vcs in use
    local P=""             # original path
    local B=""             # branch
    local PREFIX=""        # prefix
    local SUFFIX=""        # suffix used based on vcs/repo
    local REPO=""          # repo path

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
            VCS="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                VCS="$BB_BITBUCKET"
            fi
        fi

        REPO="$P" # set repo to path

        # check ssh for git@ vs https and strip
        REPO=${REPO#$sshPrefix}
        REPO=${REPO#$httpPrefix}
        REPO=${REPO#$httpsPrefix}
        REPO=${REPO#$gitPrefix}
        PREFIX="$VCS/"
        PREFIX2="$VCS:" #remove attempt 2

        # strip repo prefix/suffix
        REPO=${REPO#$PREFIX}
        REPO=${REPO#$PREFIX2}
        REPO=${REPO%$SUFFIX}

    # try mecurial
    else
        # parameters
        P="$(hg paths 2>/dev/null )"

        if [ `echo $P | grep -c "$BB_GITHUB" ` -gt 0 ] #if contains
        then
            # if github is contained in path
            VCS="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                VCS="$BB_BITBUCKET"
            fi
        fi

        # trim and remove prefix/suffix
        REPO="$(echo "$P" | sed -e 's|.*\('$VCS'.*\)|\1|')"
        PREFIX="$VCS/"
        PREFIX2="$VCS:" #remove attempt 2
        SUFFIX="/"
        REPO=${REPO#$PREFIX}
        REPO=${REPO#$PREFIX2}
        REPO=${REPO%$SUFFIX}
    fi;

    echo "https://$VCS/$REPO"
}

# returns the branch name dependent upon the current repository type
function bb__branch() {
    # Check for git in directory
    if [[ -d .git ]]; then
        local B="$(git rev-parse --abbrev-ref HEAD)"
    # try mecurial
    else
        local B="$(hg branch 2>/dev/null)"
    fi;
    echo $B
}

# returns the vcs name dependent upon the current repository type
function bb__vcs() {
    local VCS="";          # vcs in use
    local P=""             # original path

    # Check for git in directory
    if [[ -d .git ]]; then
        P="$(git config --get remote.origin.url)"

        if [ `echo $P | grep -c "$BB_GITHUB" ` -gt 0 ] #if contains
        then
            # if github is contained in remote origin path
            VCS="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                VCS="$BB_BITBUCKET"
            fi
        fi

    # try mecurial
    else
        P="$(hg paths 2>/dev/null )"

        #if contains
        if [ `echo $P | grep -c "$BB_GITHUB" ` -gt 0 ]
        then
            # if github is contained in path
            VCS="$BB_GITHUB"
        else
            # try bitbucket
            if [ `echo $P | grep -c "$BB_BITBUCKET" ` -gt 0 ]
            then
                VCS="$BB_BITBUCKET"
            fi
        fi
    fi;

    echo "$VCS"
}


# returns the branch type dependent upon repository type
function bb__branchType() {
    local VCS=$(bb__vcs)

    if [[ "$VCS" == "github.com" ]]; then
        echo "tree"
    else
        echo "branch"
    fi;
}

function bb() {
    local URL=$(bb__repo)                #result of running bb__repo function
    local B=$(bb__branch)                #result of running bb__branch function
    local BRANCH_TYPE=$(bb__branchType)  #result of running bb__branchType function
    local VCS=$(bb__vcs)                 #result of running bb__vcs function

    if [[ "$URL" == "" ]]; then
        printf "abort: no repository or branch to open (bash-bucket)\n";
    else
        local LINK="$URL/$BRANCH_TYPE/$B"
        printf "🌀 [Bash Bucket] Open Branch\n🌀 SRC  -------> $B\n🌀 REPO -------> $URL \n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function bbcomm() {
    local VCS=$(bb__vcs) #result of running bb__vcs function

    if [[ "$VCS" == "" ]]; then
        printf "abort: no repository or branch to get commit history (bash-bucket)\n";
    else
        # Returned function variables
        local URL=$(bb__repo)
        echo $URL

        local B=$(bb__branch)

        if [[ "$VCS" == "$BB_GITHUB" ]]; then
            local LINK="$URL/commits/$B"
        else
            if [[ "$VCS" == "$BB_BITBUCKET" ]]; then
                local BRANCH_TYPE=$(bb__branchType) #returns branch type
                local LINK="$URL/commits/$BRANCH_TYPE/$B"
            fi
        fi
        printf "🌀 [Bash Bucket] Commit History\n🌀 SRC  -------> $B\n🌀 REPO -------> $URL \n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function bbcomp() {
    local DEST="";
    local LINK="";

    # Returned function vars
    local URL=$(bb__repo)                #result of running bb__repo function
    local B=$(bb__branch)                #result of running bb__branch function
    local BRANCH_TYPE=$(bb__branchType)  #result of running bb__branchType function
    local VCS=$(bb__vcs)                 #result of running bb__vcs function

    if [[ "$VCS" == "" ]]; then
        printf "abort: no repository or branch to open (bash-bucket)\n";
    else
        # Check if VCS Github
        if [[ "$VCS" == "$BB_GITHUB" ]]; then

            # Destination branch compare parameter
            if [[ "$1" == "" ]]; then
                DEST="$BB_DEFAULT_GITHUB";
            else
                DEST="$1";
            fi

            # End result: http://github.com/example/repo/compare/DEST...BRANCH
            LINK="$URL/compare/$DEST...$B"

        else if [[ "$VCS" == "$BB_BITBUCKET" ]]; then
                # Destination branch compare parameter
                if [[ "$1" == "" ]]; then
                    DEST="$BB_DEFAULT_BITBUCKET";
                else
                    DEST="$1";
                fi

                # End result: http://bitbucket.org/example/repo/branch/BRANCH?dest=DEST#diff
                LINK="$URL/branch/$B?dest=$DEST#diff"
            fi
        fi
    fi


    if [[ "$URL" == "" ]]; then
        printf "abort: no repository or branch to compare (bash-bucket)\n";
    else
        printf "🌀 [Bash Bucket] Compare Branches\n🌀 SRC  -------> $B \n🌀 DEST -------> $DEST\n🌀 REPO -------> $URL \n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function pr() {
    local VCS="";
    local LINK="";

    # Returned local vars
    local URL=$(bb__repo)                #result of running bb__repo function
    local B=$(bb__branch)                #result of running bb__branch function
    local BRANCH_TYPE=$(bb__branchType)  #result of running bb__branchType function
    local VCS=$(bb__vcs)                 #result of running bb__vcs function


    if [[ "$VCS" == "" ]]; then
        printf "abort: no repository or branch to open (bash-bucket)\n";
    else
        # Check if VCS Github
        if [[ "$VCS" == "$BB_GITHUB" ]]; then

            # Destination branch compare parameter
            if [[ "$1" == "" ]]; then
                DEST="$BB_DEFAULT_GITHUB";
            else
                DEST="$1";
            fi

            # End result: http://github.com/example/repo/compare/DEST...BRANCH
            LINK="$URL/compare/$DEST...$B"

        else if [[ "$VCS" == "$BB_BITBUCKET" ]]; then
                # Destination branch compare parameter
                if [[ "$1" == "" ]]; then
                    DEST="$BB_DEFAULT_BITBUCKET";
                else
                    DEST="$1";
                fi

                # Bitbucket does not accept a DEST parameter to be passed for PR request
                LINK="$URL/pull-requests/new?source=$B&t=1"
            fi
        fi
    fi

    if [[ "$URL" == "" ]]; then
        printf "abort: no repository or branch to create a PR (bash-bucket)\n";
    else
        printf "🌀 [Bash Bucket] Pull Request\n🌀 SRC  -------> $B \n🌀 DEST -------> $DEST\n🌀 REPO -------> $URL \n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!";
    fi;
}
