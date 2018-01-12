alias ll="ls -lhA"

function bb() {
    local VCS="";
    local BRANCH_TYPE="";

    # Check for git in directory
    if [ -d .git ]; then
        VCS="github.com";
        BRANCH_TYPE="tree";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    # try mecurial
    else
        VCS="bitbucket.org";
        BRANCH_TYPE="branch";
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    fi;

    if ["$URL" == ""]
    then
        printf "abort: no repository or branch to open (bash-bucket)\n";
    else
        local LINK="$URL/$BRANCH_TYPE/$B"
        printf "Branch opened in $VCS: $B\n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function bbcomm() {
    local VCS="";
    local BRANCH_TYPE="";

    # Check for git in directory
    if [ -d .git ]; then
        VCS="github.com";
        BRANCH_TYPE="";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    # try mecurial
    else
        VCS="bitbucket.org";
        BRANCH_TYPE="branch";
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    fi;

    if ["$URL" == ""];
    then
        printf "abort: no repository or branch to get commit history (bash-bucket)\n";
    else
        local LINK="$URL/commits/$BRANCH_TYPE$B"
        printf "Commit history for branch: $B\n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function bbcomp() {
    local VCS="";
    local BRANCH_TYPE="";
    local DEST="";

    # Check for git in directory
    if [ -d .git ]; then
        VCS="github.com";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"

        # Destination branch compare parameter
        if [ "$1" == ""];
        then
            DEST="master";
        else
            DEST="$1";
        fi;

        # End result: http://github.com/example/repo/compare/DEST...BRANCH
        local LINK="$URL/compare/$DEST...$B"
    # try mecurial
    else
        VCS="bitbucket.org";
        BRANCH_TYPE="branch";
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\('$VCS'.*\)|http://\1|')"

        # Destination branch compare parameter
        if [ "$1" == ""];
        then
            DEST="develop";
        else
            DEST="$1";
        fi;

        # End result: http://bitbucket.org/example/repo/branch/BRANCH?dest=DEST#diff
        local LINK="$URL/$BRANCH_TYPE/$B?dest=$DEST#diff"
    fi;

    if ["$URL" == ""]
    then
        printf "abort: no repository or branch to compare (bash-bucket)\n";
    else
        printf "Compare Branches [source:$B -> dest:$DEST]\n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function pr() {
    local VCS="";
    local BRANCH_TYPE="";

    # Check for git in directory
    if [[ -d .git ]]; then
        VCS="github.com";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"

        # Destination branch compare parameter
        if [[ "$1" == ""]];
        then
            DEST="master";
        else
            DEST="$1";
        fi;

        # End result: http://github.com/example/repo/compare/DEST...BRANCH
        local LINK="$URL/compare/$DEST...$B"
    # try mecurial
    else
        VCS="bitbucket.org";
        local P="$(hg paths 2>/dev/null | grep 'bitbucket.org' | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\(bitbucket.org.*\)|http://\1|')"

        # Bitbucket does not accept a DEST parameter to be passed for PR request
        local LINK="$URL/pull-requests/new?source=$B&t=1"
    fi;

    if [[ "$URL" == "" ]];
    then
        printf "abort: no repository or branch to create a PR (bash-bucket)\n";
    else
        printf "PR for branch: $B\n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}



# Additional quick functions WIP
function chrome(){
    # TODO: fix https
    local site=""
    if [[ -f "$(pwd)/$1" ]]; then
        site="$(pwd)/$1"
    elif [[ "$1" =~ "^http" ]]; then
        site="$1"
    else
        site="http://$1"
    fi
    /usr/bin/open -a "/Applications/Google Chrome.app" "$site";
}

function firefox(){
    # TODO: fix https
    local site=""
    if [[ -f "$(pwd)/$1" ]]; then
        site="$(pwd)/$1"
    elif [[ "$1" =~ "^http" ]]; then
        site="$1"
    else
        site="http://$1"
    fi
    /usr/bin/open -a "/Applications/Firefox.app" "$site";
}
