#!/usr/bin/env bash

echo "build web: $1"

projectDir="project/$1"

devServer="root@dev1.pinquest.cn"
devServerDeployPath="/home/pinfire/weblogic/public/$1"

cd $projectDir
npm i --registry=https://registry.npm.taobao.org

case "$4" in
  "refs/heads/master")
    npm run build
    ssh $devServer mkdir -p $devServerDeployPath
    rsync -a dist/* $devServer:$devServerDeployPath
    ;;

  "refs/heads/develop")
    npm run build:dev
    mkdir -p $devServerDeployPath
    cp -ufr ./dist/* $devServerDeployPath
    ;;
esac

exit 0
