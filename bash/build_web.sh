#!/usr/bin/env bash

echo "build web: $1"

projectDir="project/$1"

devServer="root@dev1.pinquest.cn"
devServerDeployPath="/home/pinfire/weblogic/public/$1"

cd $projectDir

case "$4" in
  "refs/heads/master")
    npm run build
    ssh $devServer mkdir -p $devServerDeployPath
    rsync -a dist/* $devServer:$devServerDeployPath
    ;;

  "refs/heads/develop")
    npm run build:dev
    ;;
esac

exit 0