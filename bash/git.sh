#!/usr/bin/env bash

# $1 repository namespace name
# $2 repository url
# $2 event
# $3 branch

echo "sync code $1"

projectDir="project/$1"

if [ ! -f "$1" ]; then
  git clone $2 $projectDir
fi

cd $projectDir

case "$4" in
  "refs/heads/master")
    git fetch --all && git reset --hard master && git pull origin master
    ;;

  "refs/heads/develop")
    git fetch --all && git reset --hard develop && git pull origin develop
    ;;
esac

exit 0