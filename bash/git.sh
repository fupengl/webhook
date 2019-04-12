#!/usr/bin/env bash

# $1 repository namespace
# $2 repository name
# $3 repository url
# $4 event
# $5 branch

echo "sync code $1"

projectDir="project/$1"

if [ ! -f "$1" ]; then
  git clone $3 $projectDir
fi

cd $projectDir
git fetch --all

case "$5" in
  "refs/heads/master")
    git checkout -f master && git reset --hard master && git pull origin master
    ;;

  "refs/heads/develop")
    git checkout -f develop && git reset --hard develop && git pull origin develop
    ;;
esac

exit 0