#!/bin/bash
set -e

# Set Git credentials in the continuous integration environment
if [ "$CI" = 'Y' ]
then
  git config --global user.email 'ci@example.com'
  git config --global user.name 'Continuous Integration'
fi

bash credentials.sh

GIT_EMAIL="$(git config user.email)"
GIT_NAME="$(git config user.name)"

echo "$GIT_EMAIL" > tmp/git_email.txt
echo "$GIT_NAME" > tmp/git_name.txt

echo '+++++++++++++++++++++++++++'
echo 'BEGIN: docker-compose build'
echo '+++++++++++++++++++++++++++'
docker-compose build
echo '+++++++++++++++++++++++++'
echo 'END: docker-compose build'
echo '+++++++++++++++++++++++++'

echo '#################################################'
echo 'BEGIN: docker-compose run web bash build-rails.sh'
echo '#################################################'
docker-compose run web bash build-rails.sh
echo '###############################################'
echo 'END: docker-compose run web bash build-rails.sh'
echo '###############################################'

APP_NAME=`cat tmp/app_name.txt`
# In the GitHub Workflows continuous integration environment,
# tasks are executed as user "runner", but the app is owned by
# "runneradmin".
echo '-------'
echo "CI: $CI"
if [ "$CI" = 'Y' ]
then
  echo '---------------'
  echo 'TROUBLESHOOTING'
  sudo chown -R runner:runner $PWD
  ls -l
fi
echo '#######'
echo 'NEW APP'
echo 'BEGIN: docker/build'
echo '###################'
cd $APP_NAME && docker/build
