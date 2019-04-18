#!/usr/bin/env bash

# $WEBHOOK_PROJECT_NAME repository namespace
# $WEBHOOK_DEPLOY_PATH repository deploy path
# $WEBHOOK_REPOSITORY_URL repository url
# $WEBHOOK_REPOSITORY_EVENT event
# $WEBHOOK_REPOSITORY_BRANCH branch

echo "build web: $WEBHOOK_PROJECT_NAME"

projectDir="project/$WEBHOOK_PROJECT_NAME"

prodServer=("root@172.18.111.162")

DeployPath="/home/pinfire/weblogic/public/$WEBHOOK_DEPLOY_PATH"

cd $projectDir

npm config set strict-ssl false 
npm i -s -f --no-audit --no-package-lock --package-lock-only --global-style --no-shrinkwrap --reg=https://registry.npm.taobao.org
rm -rf dist/

case "$WEBHOOK_REPOSITORY_BRANCH" in
  "master")
    npm run build
    for server in ${prodServer[@]}
    do
        ssh $prodServer mkdir -p $DeployPath
        rsync -avz --progress dist/* $server:$DeployPath
        echo "deploy to "$server
    done
    echo "deploy $WEBHOOK_DEPLOY_PATH prod server successfully"
    ;;

  "develop")
    npm run build:dev
    mkdir -p $DeployPath
    cp -ufr ./dist/* $DeployPath
    echo "deploy $WEBHOOK_DEPLOY_PATH develop server successfully"
    ;;
esac

exit 0
