#!/bin/bash
set -e

mkdir -p tmp

RAILS_VERSION='6'
MODE='v0'
echo 'N' > tmp/host_env.txt
echo 'N' > tmp/annotate.txt

DATE=`date -u +%Y%m%d-%H%M%S-%3N`
APP_NAME="rails$RAILS_VERSION$MODE-$DATE"
echo "$DATE" > tmp/time_stamp.txt
echo "$APP_NAME" > tmp/app_name.txt

echo 'Y' > tmp/from_scratch.txt
echo 'N' > tmp/dockerize.txt
echo 'N' > tmp/add_lint.txt
echo 'N' > tmp/add_vulnerability_tests.txt
echo 'N' > tmp/add_static_pages.txt
echo 'N' > tmp/add_other.txt

mkdir -p log
bash $PWD/build-rails.sh 2>&1 | tee log/$APP_NAME.txt
