#!/usr/bin/env bash

# $WEBHOOK_PROJECT_NAME repository namespace
# $WEBHOOK_DEPLOY_PATH repository deploy path
# $WEBHOOK_REPOSITORY_URL repository url
# $WEBHOOK_REPOSITORY_EVENT event
# $WEBHOOK_REPOSITORY_BRANCH branch

source ./bash/git_branch.sh

echo "> build web: $WEBHOOK_PROJECT_NAME"

projectDir="project/$WEBHOOK_PROJECT_NAME"

cd $projectDir

prodServer=("root@172.18.111.162")
devServer=("root@172.18.239.251")

DeployDir="/home/pinfire/weblogic/public"
DeployPath="$DeployDir/$WEBHOOK_DEPLOY_PATH"
PkgPath="/var/webpkg/$WEBHOOK_PROJECT_NAME/$(get_branch_hash)"

echo $DeployPath
echo $PkgPath

function deploy() {
    echo "> deploy to $1 ..."
    ssh $server "mkdir -p $DeployDir $PkgPath"
    rsync -avz --progress dist/* $1:$PkgPath
    ssh $server "rm -rf $DeployPath && ln -s $PkgPath $DeployPath"
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
