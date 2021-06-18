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

docker-compose build

docker-compose run web bash build-rails.sh
