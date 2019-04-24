#!/usr/bin/env bash

# $WEBHOOK_PROJECT_NAME repository namespace
# $WEBHOOK_DEPLOY_PATH repository deploy path
# $WEBHOOK_REPOSITORY_URL repository url
# $WEBHOOK_REPOSITORY_EVENT event
# $WEBHOOK_REPOSITORY_BRANCH branch

echo "> build web: $WEBHOOK_PROJECT_NAME"

projectDir="project/$WEBHOOK_PROJECT_NAME"

prodServer=("root@172.18.111.162")
devServer=("root@172.18.239.251")

DeployPath="/home/pinfire/weblogic/public/$WEBHOOK_DEPLOY_PATH"

cd $projectDir

rm -rf dist/

case "$WEBHOOK_REPOSITORY_BRANCH" in
  "master")
    yarn && yarn build
    for server in ${prodServer[@]}
    do
        echo "> deploy to "$server" ..."
        ssh $server mkdir -p $DeployPath
        rsync -avz --progress dist/* $server:$DeployPath
    done
    echo "> deploy $WEBHOOK_DEPLOY_PATH prod server successfully"
    ;;

  "develop")
    yarn && yarn build:dev
    for server in ${devServer[@]}
    do
        echo "> deploy to "$server" ..."
        ssh $server mkdir -p $DeployPath
        rsync -avz --progress dist/* $server:$DeployPath
    done
    echo "> deploy $WEBHOOK_DEPLOY_PATH develop server successfully"
    ;;
esac

exit 0
