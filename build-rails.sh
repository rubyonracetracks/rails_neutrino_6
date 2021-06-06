#!/bin/bash
set -e

APP_NAME=$1

#############
# Preparation
#############

DIR_MAIN=$PWD

DIR_APP=$DIR_MAIN/$APP_NAME

echo '-------'
echo 'ruby -v'
ruby -v

echo '-------------------'
echo 'cat /etc/os-release'
cat /etc/os-release
echo ''

echo '-----------------'
echo 'bundler --version'
bundler --version
echo ''

echo '--------------------'
echo 'gem list "^bundler$"'
gem list "^bundler$"
echo ''

echo '--------'
echo 'rails -v'
rails -v
echo ''

echo '---------'
echo 'App Name:'
echo "$APP_NAME"
echo ''

BASE_APP_URL='' # Will be updated later if necessary
HOST_ENV=`cat tmp/host_env.txt`
ANNOTATE=`cat tmp/annotate.txt`
FROM_SCRATCH=`cat tmp/from_scratch.txt`
DOCKERIZE=`cat tmp/dockerize.txt`
ADD_LINT=`cat tmp/add_lint.txt`
ADD_VULNERABILITY_TESTS=`cat tmp/add_vulnerability_tests.txt`
ADD_STATIC_PAGES=`cat tmp/add_static_pages.txt`
ADD_OTHER=`cat tmp/add_other.txt`

echo '-----------------'
echo 'Scope parameters:'
echo ''
echo "Host environment?                     $HOST_ENV"
echo ''
echo "Create app from scratch?              $FROM_SCRATCH"
echo ''
echo "Dockerize?                            $DOCKERIZE"
echo ''
echo "Add RuboCop and Rails Best Practices? $ADD_LINT"
echo ''
echo "Add vulnerability tests?              $ADD_VULNERABILITY_TESTS"
echo ''
echo "Add static pages                      $ADD_STATIC_PAGES"
echo ''
echo "Add other features?                   $ADD_OTHER"
echo ''
echo "Run annotate at each step?            $ANNOTATE"
echo ''

DIR_APP=$PWD/$APP_NAME

echo '--------------------------------'
echo 'BEGIN: installing necessary gems'
echo '--------------------------------'
gem install insert_from_file
gem install line_containing
gem install gemfile_entry
gem install string_in_file
gem install replace_quotes
gem install remove_double_blank
echo '------------------------------'
echo 'END: installing necessary gems'
echo '------------------------------'

########################################
# 01-01: Initial app creation/acqusition
########################################
prepare_mod_app () {
  cp $DIR_MAIN/mod_app.sh $DIR_APP
  wait
  cp -R $DIR_MAIN/mod $DIR_APP
  wait
}

get_base_app_url_host () {
   # Fill in later
   BASE_APP_URL=``
}

get_base_app_url_virtual () {
  if [ "$DOCKERIZE" = 'Y' ]
  then
    BASE_APP_URL=`cat base_apps/v1.txt`
  fi
}

get_base_app_url () {
  if [ "$HOST_ENV" = 'Y' ]
  then
    get_base_app_url_host
  else
    get_base_app_url_virtual
  fi
}

download_base_app () {
  get_base_app_url
  git clone "$BASE_APP_URL" "$APP_NAME"
}

if [ "$FROM_SCRATCH" = 'Y' ]
then
  # Create new app from scratch
  echo '--------------------------'
  echo "BEGIN: rails new $APP_NAME"
  echo '--------------------------'
  cd $DIR_MAIN && rails new $APP_NAME
  echo '------------------------'
  echo "END: rails new $APP_NAME"
  echo '------------------------'
  echo "$APP_NAME" > $DIR_APP/config/time_stamp.txt
  prepare_mod_app
  cd $DIR_APP && bash mod_app.sh '01-01' $TOGGLE_OUTLINE
else
  download_base_app
  prepare_mod_app
fi

###############
# DOCKERIZATION
###############
if [ "$DOCKERIZE" = 'Y' ]
then
  cd $DIR_APP && bash mod_app.sh '01-02' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '01-03' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '01-04' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '01-05' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '01-06' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '01-07' $TOGGLE_OUTLINE
fi

#########
# CLEANUP
#########
# Remove the mod* files from the new app

echo 'Cleaning up the app'
rm -rf $DIR_APP/mod
rm $DIR_APP/mod*
