#!/usr/bin/env bash

# $WEBHOOK_PROJECT_NAME repository namespace
# $WEBHOOK_DEPLOY_PATH repository deploy path
# $WEBHOOK_REPOSITORY_URL repository url
# $WEBHOOK_REPOSITORY_EVENT event
# $WEBHOOK_REPOSITORY_BRANCH branch

source ./git_branch.sh

echo "> build web: $WEBHOOK_PROJECT_NAME"

projectDir="project/$WEBHOOK_PROJECT_NAME"

cd $projectDir

prodServer=("root@172.18.111.162")
devServer=("root@172.18.239.251")

DeployPath="/home/pinfire/weblogic/public/$WEBHOOK_DEPLOY_PATH"
PkgPath="/var/webpkg/$WEBHOOK_PROJECT_NAME/$(get_bran_hash)"

function deploy() {
    echo "> deploy to $1 ..."
    ssh $server mkdir -p "$DeployPath $PkgPath && ln -s $PkgPath $DeployPath"
    rsync -avz --progress dist/* $1:$PkgPath
    echo "> deploy $1 server successfully"
}

case "$WEBHOOK_REPOSITORY_BRANCH" in
  "master")
    yarn && yarn build
    for server in ${prodServer[@]}
    do
        deploy $server
    done
    ;;

  "develop")
    yarn && yarn build:dev
    for server in ${devServer[@]}
    do
        deploy $server
    done
    ;;
esac

exit 0
