#!/bin/bash
set -e

bash credentials.sh
mkdir -p variables

RAILS_VERSION='6'
MODE='h1'
echo 'Y' > variables/host_env.txt
echo 'N' > variables/annotate.txt

DATE=`date -u +%Y%m%d-%H%M%S-%3N`
APP_NAME="rails$RAILS_VERSION$MODE-$DATE"
echo "$DATE" > variables/time_stamp.txt
echo "$APP_NAME" > variables/app_name.txt

echo 'Y' > variables/from_scratch.txt
echo 'Y' > variables/dockerize.txt
echo 'N' > variables/add_lint.txt
echo 'N' > variables/add_vulnerability_tests.txt
echo 'N' > variables/add_static_pages.txt
echo 'N' > variables/add_other.txt

ls -l

bash nukec.sh
mkdir -p log
docker build . 2>&1 | tee log/$APP_NAME.txt
