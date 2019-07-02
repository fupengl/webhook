#!/usr/bin/env bash

# $WEBHOOK_PROJECT_NAME repository namespace
# $WEBHOOK_DEPLOY_PATH repository deploy path
# $WEBHOOK_REPOSITORY_URL repository url
# $WEBHOOK_REPOSITORY_EVENT event
# $WEBHOOK_REPOSITORY_BRANCH branch

source ./bash/git_branch.sh

echo "> build web: $WEBHOOK_PROJECT_NAME"

projectDir="project/$WEBHOOK_PROJECT_NAME"
base=$(cd "$(dirname "$0")";pwd)

cd $projectDir

branchHash=$(get_branch_hash)

localPkg="$base/../pkg/$WEBHOOK_PROJECT_NAME/$branchHash"

prodServer=("root@172.18.111.162")
devServer=("root@172.18.239.251" "root@172.18.111.168")

DeployDir="/home/pinfire/weblogic/public"
DeployPath="$DeployDir/$WEBHOOK_DEPLOY_PATH"
PkgPath="/home/pinfire/webpkg/$WEBHOOK_PROJECT_NAME/$branchHash"

function deploy() {
    echo "> deploy to $1 ..."
    ssh $server "mkdir -p $2 $PkgPath" || exit 1
    rsync -avz --progress $localPkg/* $1:$PkgPath || exit 1
    ssh $server "rm -rf $2 && ln -s $PkgPath $2" || exit 1
    echo "> deploy $1 server successfully"
}

function checkexec() {
    if [ ! -z "$1"  ]; then
      if [ ! -d "$localPkg" ]; then
        eval $1 && mkdir -p $localPkg && cp -rf dist/* $localPkg || exit 1
      fi
    fi
}

case "$WEBHOOK_REPOSITORY_BRANCH" in
  "master")
    checkexec "yarn --no-lockfile && yarn build"
    for server in "${prodServer[@]}"
    do
        deploy "$server" "$DeployPath"
    done
    ;;

  "develop")
    checkexec "yarn --no-lockfile && yarn build:dev"
    for server in "${devServer[@]}"
    do
        deploy "$server" "$DeployPath"
    done
    ;;
esac

exit 0
