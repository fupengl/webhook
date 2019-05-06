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
$branchHash=$(get_branch_hash)

prodServer=("root@172.18.111.162")
devServer=("root@172.18.239.251")

DeployDir="/home/pinfire/weblogic/public"
DeployPath="$DeployDir/$WEBHOOK_DEPLOY_PATH"
PkgPath="/var/webpkg/$WEBHOOK_PROJECT_NAME/$branchHash"
LocalPkg="pkg/$WEBHOOK_PROJECT_NAME/${$branchHash}"

echo $DeployPath
echo $PkgPath

function deploy() {
    echo "> deploy to $1 ..."
    ssh $server "mkdir -p $DeployDir $PkgPath"
    rsync -avz --progress LocalPkg/* $1:$PkgPath
    ssh $server "rm -rf $DeployPath && ln -s $PkgPath $DeployPath"
    echo "> deploy $1 server successfully"
}

function checkexec() {
    if [ ! -z "$1"  ]; then
      if [ ! -f "$LocalPkg" ]; then
        `$1`
        mkdir -p $LocalPkg && cp -rf dist/* $LocalPkg
      fi
    fi
}

case "$WEBHOOK_REPOSITORY_BRANCH" in
  "master")
    checkexec "yarn && yarn build"
    for server in ${prodServer[@]}
    do
        deploy $server
    done
    ;;

  "develop")
    checkexec "yarn && yarn build:dev"
    for server in ${devServer[@]}
    do
        deploy $server
    done
    ;;
esac

exit 0
