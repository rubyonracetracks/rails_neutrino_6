#!/bin/bash
set -e

# Set Git credentials in the continuous integration environment
if [ "$CI" = 'true' ]
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

APP_NAME=`cat tmp/app_name.txt`
if [ "$CI" = 'true' ]
then
  echo '#####################################################'
  echo "BEGIN: docker-compose run web bash build-rails.sh 'Y'"
  echo '#####################################################'
  docker-compose run web bash build-rails.sh 'Y'
  echo '###################################################'
  echo "END: docker-compose run web bash build-rails.sh 'Y'"
  echo '###################################################'
else
  echo '#################################################'
  echo 'BEGIN: docker-compose run web bash build-rails.sh'
  echo '#################################################'
  docker-compose run web bash build-rails.sh
  echo '###############################################'
  echo 'END: docker-compose run web bash build-rails.sh'
  echo '###############################################'
  echo '#######'
  echo 'NEW APP'
  echo 'BEGIN: docker/build'
  echo '###################'
  cd $APP_NAME && docker/build
  echo '#######'
  echo 'NEW APP'
  echo 'END: docker/build'
  echo '#################'
fi
echo '**********************************'
echo 'Your new Rails app has been built!'
echo 'Path:'
echo "$PWD/$APP_NAME"
