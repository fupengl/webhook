#!/usr/bin/env bash

echo "build web: $1"

projectDir="project/$1"

prodServer="root@120.79.155.84"

DeployPath="/home/pinfire/weblogic/public/$2"

cd $projectDir
npm i --registry=https://registry.npm.taobao.org

case "$5" in
  "refs/heads/master")
    npm run build
    ssh $prodServer mkdir -p $DeployPath
    rsync -avz --progress dist/* $prodServer:$DeployPath
    echo "deploy prod server successfully"
    ;;

  "refs/heads/develop")
    npm run build:dev
    mkdir -p $DeployPath
    cp -ufr ./dist/* $DeployPath
    echo "deploy develop server successfully"
    ;;
esac

exit 0
