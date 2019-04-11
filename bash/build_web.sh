#!/usr/bin/env bash

echo "build $1"

projectDir="project/$1"

if [ ! -f "$1" ]; then
  git clone $2 $projectDir
fi

cd $projectDir

case "$4" in
  "refs/heads/master")
    echo "123"
    ;;

  "refs/heads/develop")
    git fetch --all && git reset --hard develop && git pull origin develop
    ;;
esac

exit 0