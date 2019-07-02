#!/usr/bin/env bash

# $WEBHOOK_PROJECT_NAME repository namespace
# $WEBHOOK_DEPLOY_PATH repository deploy path
# $WEBHOOK_REPOSITORY_URL repository url
# $WEBHOOK_REPOSITORY_EVENT event
# $WEBHOOK_REPOSITORY_BRANCH branch

echo "> pull code $WEBHOOK_PROJECT_NAME branch $WEBHOOK_REPOSITORY_BRANCH"

projectDir="project/$WEBHOOK_PROJECT_NAME"

if [ ! -d "$projectDir" ]; then
  echo "cloning $WEBHOOK_PROJECT_NAME"
  git clone $WEBHOOK_REPOSITORY_URL $projectDir
fi

cd $projectDir
git fetch --all

case "$WEBHOOK_REPOSITORY_BRANCH" in
  "master")
    ;;

  "develop")
    ;;
esac

git checkout -f $WEBHOOK_REPOSITORY_BRANCH
git reset --hard $WEBHOOK_REPOSITORY_BRANCH
git pull origin $WEBHOOK_REPOSITORY_BRANCH

exit 0
