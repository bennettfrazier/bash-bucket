function bb() {
    local VCS="";
    local BRANCH_TYPE="";

    # Check for git in directory
    if [[ -d .git ]]; then
        VCS="github.com";
        BRANCH_TYPE="tree";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo "$P" | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    # try mecurial
    else
        VCS="bitbucket.org";
        BRANCH_TYPE="branch";
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo "$P" | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    fi;

    if [[ "$URL" == "" ]]; then
        printf "abort: no repository or branch to open (bash-bucket)\n";
    else
        local LINK="$URL/$BRANCH_TYPE/$B"
        printf "🌀 [Bash Bucket] Open Branch\n🌀 SRC  -------> $B\n🌀 REPO -------> $URL \n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function bbcomm() {
    local VCS="";
    local BRANCH_TYPE="";

    # Check for git in directory
    if [[ -d .git ]]; then
        VCS="github.com";
        BRANCH_TYPE="";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo "$P" | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    # try mecurial
    else
        VCS="bitbucket.org";
        BRANCH_TYPE="branch";
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo "$P" | sed -e's|.*\('$VCS'.*\)|http://\1|')"
    fi;

    if [[ "$URL" == "" ]]; then
        printf "abort: no repository or branch to get commit history (bash-bucket)\n";
    else
        local LINK="$URL/commits/$BRANCH_TYPE$B"
        printf "🌀 [Bash Bucket] Commit History\n🌀 SRC  -------> $B\n🌀 REPO -------> $URL \n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!"
    fi;
}

function bbcomp() {
    local VCS="";
    local DEST="";
    local LINK="";

    # Check for git in directory
    if [[ -d .git ]]; then
        VCS="github.com";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo "$P" | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"

        # Destination branch compare parameter
        if [[ "$1" == "" ]]; then
            DEST="master";
        else
            DEST="$1";
        fi

        # End result: http://github.com/example/repo/compare/DEST...BRANCH
        LINK="$URL/compare/$DEST...$B"
    # try mecurial
    else
        VCS="bitbucket.org";
        local P="$(hg paths 2>/dev/null | grep $VCS | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo "$P" | sed -e's|.*\('$VCS'.*\)|http://\1|')"

        # Destination branch compare parameter
        if [[ "$1" == "" ]]; then
            DEST="develop";
        else
            DEST="$1";
        fi

        # End result: http://bitbucket.org/example/repo/branch/BRANCH?dest=DEST#diff
        LINK="$URL/branch/$B?dest=$DEST#diff"
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

    # Check for git in directory
    if [[ -d .git ]]; then
        VCS="github.com";
        local P="$(git config --get remote.origin.url)"
        local B="$(git rev-parse --abbrev-ref HEAD)"
        local URL="$(echo "$P" | sed -e 's/:/\//g' | sed -e 's/\.git//g' | sed -e's|.*\('$VCS'.*\)|http://\1|')"

        # Destination branch compare parameter
        if [[ "$1" == "" ]]; then
            DEST="master";
        else
            DEST="$1";
        fi

        # End result: http://github.com/example/repo/compare/DEST...BRANCH
        LINK="$URL/compare/$DEST...$B"
    # try mecurial
    else
        VCS="bitbucket.org";
        local P="$(hg paths 2>/dev/null | grep 'bitbucket.org' | head -1)"
        local B="$(hg branch 2>/dev/null)"
        local URL="$(echo "$P" | sed -e's|.*\(bitbucket.org.*\)|http://\1|')"

        # Bitbucket does not accept a DEST parameter to be passed for PR request
        LINK="$URL/pull-requests/new?source=$B&t=1"
    fi

    if [[ "$URL" == "" ]]; then
        printf "abort: no repository or branch to create a PR (bash-bucket)\n";
    else
        printf "🌀 [Bash Bucket] Pull Request\n🌀 SRC  -------> $B \n🌀 DEST -------> $DEST\n🌀 REPO -------> $URL \n";
        [[ -n $LINK ]] && open $LINK || echo "No $VCS path found!";
    fi;
}
