#!/usr/bin/env bash

echo "build $1"

projectDir="project/$1"

if [ ! -f "$1" ]; then
  git clone $2 $projectDir
fi

cd $projectDir

case "$4" in
  "refs/heads/master")
    npm run build
    ;;

  "refs/heads/develop")
    npm run build:dev
    ;;
esac

exit 0