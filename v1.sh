#!/bin/bash
set -e

bash credentials.sh
mkdir -p tmp_vars

RAILS_VERSION='6'
MODE='v1'
echo 'N' > tmp_vars/host_env.txt
echo 'N' > tmp_vars/annotate.txt

DATE=`date -u +%Y%m%d-%H%M%S-%3N`
APP_NAME="rails$RAILS_VERSION$MODE-$DATE"
echo "$DATE" > tmp_vars/time_stamp.txt
echo "$APP_NAME" > tmp_vars/app_name.txt

echo 'N' > tmp_vars/from_scratch.txt
echo 'Y' > tmp_vars/dockerize.txt
echo 'N' > tmp_vars/add_lint.txt
echo 'N' > tmp_vars/add_vulnerability_tests.txt
echo 'N' > tmp_vars/add_static_pages.txt
echo 'N' > tmp_vars/add_other.txt

mkdir -p log
bash $PWD/build-rails.sh 2>&1 | tee log/$APP_NAME.txt
