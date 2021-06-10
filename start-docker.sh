#!/bin/bash
set -e

bash credentials.sh

docker run -i -t --rm -v ${PWD}:/home/winner/neutrino registry.gitlab.com/rubyonracetracks/docker-debian-bullseye-rvm-rails-neutrino6 /home/winner/neutrino/start-build-rails

APP_NAME=`cat tmp/app_name.txt`
DIR_APP=$PWD/$APP_NAME
cd $DIR_APP && docker/build
echo '**********************************'
echo 'Your new Rails app has been built!'
echo 'Path:'
echo "$DIR_APP"
