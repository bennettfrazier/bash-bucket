alias ll="ls -lhA"

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

function ffox(){
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

function bb() {
    local VCS="";
    local BRANCH_TYPE="";
    if [ "$1" == "" ];  # Is parameter #1 empty
    then
        # TODO: simplify without flags
        VCS="bitbucket.org";
        BRANCH_TYPE="branch";
    else
        if [ "$1" == "-g" ];
        then
            VCS="github.com";
            BRANCH_TYPE="tree";
        fi;
    fi;

    # if git exists in directory
    if [ -d .git ]; then
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    # try mecurial
    else
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    fi;

    if ["$URL" == ""]
    then
        printf "abort: no repository or branch to open (bash-bucket)\n";
    else
        local LINK="$URL/$BRANCH_TYPE/$B"
        printf "Branch opened in Bitbucket: $B\n";
        [[ -n $LINK ]] && open $LINK || echo "No Bitbucket path found!"
    fi;
}

function bbcomm() {
    local VCS="";
    local BRANCH_TYPE="";
    if [ "$1" == "" ];  # Is parameter #1 empty
    then
        # TODO: simplify without flags
        VCS="bitbucket.org";
        BRANCH_TYPE="branch/";
    else
        if [ "$1" == "-g" ];
        then
            VCS="github.com";
            BRANCH_TYPE="";
        fi;
    fi;

    # if git exists in directory
    if [ -d .git ]; then
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    # try mecurial
    else
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    fi;

    if ["$URL" == ""]
    then
        printf "abort: no repository or branch to get commit history (bash-bucket)\n";
    else
        local LINK="$URL/commits/$BRANCH_TYPE$B"
        printf "Commit history for branch: $B\n";
        [[ -n $LINK ]] && open $LINK || echo "No Bitbucket path found!"
    fi;
}

function bbcomp() {
    local VCS="";
    local BRANCH_TYPE="";
    if [ "$1" == "" ];  # Is parameter #1 empty
    then
        # TODO: simplify without flags
        VCS="bitbucket.org";
        BRANCH_TYPE="branch/";
    else
        if [ "$1" == "-g" ];
        then
            VCS="github.com";
            BRANCH_TYPE="";
        fi;
    fi;

    # if git exists in directory
    local DEST="";
    if [ -d .git ]; then
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    # try mecurial
    else
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    fi;

    # changes 1st parameter to the destination code compare
    if [ "$1" == ""];  # Is parameter #1 empty
    then
        DEST="develop";
    else
        DEST="$1";
    fi;
    if ["$URL" == ""]
    then
        printf "abort: no repository or branch to compare (bash-bucket)\n";
    else
        local LINK="$URL/branch/$B?dest=$DEST#diff"
        printf "Compare Branches [source:$B -> dest:$DEST]\n";
        [[ -n $LINK ]] && open $LINK || echo "No Bitbucket path found!"
    fi;
}

function pr() {
    # if git exists in directory
    if [ -d .git ]; then
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo $P | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\(bitbucket.org.*\)|http://\1|')"
    # try mecurial
    else
        local P="$(hg paths 2>/dev/null | grep 'bitbucket.org' | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo $P | sed -e's|.*\(bitbucket.org.*\)|http://\1|')"
    fi;

    if ["$URL" == ""]
    then
        printf "abort: no repository or branch to create a PR (bash-bucket)\n";
    else
        local LINK="$URL/pull-requests/new?source=$B&t=1"
        printf "PR for branch: $B\n";
        [[ -n $LINK ]] && open $LINK || echo "No Bitbucket path found!"
    fi;
}
