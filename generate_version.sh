#!/bin/bash
usage()
{
cat << EOF
usage: $0 options

This script changes version in config to dynamic version based on information from GIT repository

OPTIONS:
   -h      Show this message
   -p      Create production release version
EOF
}
while getopts "h:p" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         p)
             PRODUCTION_VERSION=true
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

DEFAULT_PRODUCTION_BRANCH=main
CURRENT_BRANCH=`git symbolic-ref --short HEAD`
CURRENT_BRANCH_PRODUCTION=`git rev-parse --abbrev-ref HEAD`
SHORT_GIT_HASH=`git rev-parse --short HEAD`
NEAREST_GIT_TAG=`git describe --tags --candidates 1 $SHORT_GIT_HASH --always | awk -F- '{print $1}'`

if [ -z $PRODUCTION_VERSION ]; then
    if [ "$CURRENT_BRANCH" ]; then
        VERSION=$CURRENT_BRANCH+$SHORT_GIT_HASH
    else
        VERSION=$SHORT_GIT_HASH
    fi
else
    if [ "$CURRENT_BRANCH_PRODUCTION" = "$DEFAULT_PRODUCTION_BRANCH" ]; then
        VERSION=$NEAREST_GIT_TAG
    elif [ "$CURRENT_BRANCH_PRODUCTION" ]; then
        VERSION=$NEAREST_GIT_TAG
    else
        VERSION=$SHORT_GIT_HASH
    fi
fi
echo $VERSION