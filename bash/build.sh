#!/usr/bin/env bash

# $1 repository namespace name
# $2 repository url
# $2 event
# $3 branch

echo "start build $1"

if [ ! -f "$1" ]; then
  git clone $2 $1
fi