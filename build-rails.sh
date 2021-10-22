#!/bin/bash
set -e

# Basic parameters
BASE_APP_URL='' # Will be updated later if necessary
HOST_ENV=`cat tmp/host_env.txt`
ANNOTATE=`cat tmp/annotate.txt`
FROM_SCRATCH=`cat tmp/from_scratch.txt`
DOCKERIZE=`cat tmp/dockerize.txt`
ADD_LINT=`cat tmp/add_lint.txt`
ADD_VULNERABILITY_TESTS=`cat tmp/add_vulnerability_tests.txt`
ADD_STATIC_PAGES=`cat tmp/add_static_pages.txt`
ADD_OTHER=`cat tmp/add_other.txt`

# Preparation steps needed if this script was initiated in the host environment
if [ "$HOST_ENV" = 'Y' ]
then
  echo 'Automatcally setting Git credentials in Docker environment'

  # Git credentials
  GIT_EMAIL=`cat tmp/git_email.txt`
  GIT_NAME=`cat tmp/git_name.txt`
  git config --global user.email "$GIT_EMAIL"
  git config --global user.name "$GIT_NAME"
else
  # Git credentials
  bash credentials.sh
fi

# Display parameters
DIR_MAIN=$PWD
APP_NAME=`cat $DIR_MAIN/tmp/app_name.txt`
DIR_APP=$DIR_MAIN/$APP_NAME

echo '---------'
echo 'App Name:'
echo "$APP_NAME"
echo ''

echo '----------'
echo 'Git email:'
git config --global user.email
echo ''
echo '---------'
echo 'Git name:'
git config --global user.name

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

####################################################################
# Activate NVM and RVM if this script was triggered from the host OS
####################################################################
if [ "$HOST_ENV" = 'Y' ]
then
  export NVM_DIR="/home/`whoami`/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm use node

  export PATH="$PATH:$HOME/.rvm/bin"
  source ~/.rvm/scripts/rvm
fi

#######################
# Initial sanity checks
#######################

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

if [ "$CI" = 'true' ]
then
  echo '-----------------'
  echo 'gem install rails'
  gem install rails
fi

echo '--------'
echo 'rails -v'
rails -v
echo ''

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
  elif [ "$ADD_LINT" = 'Y' ]
  then
    BASE_APP_URL=`cat base_apps/v2.txt`
  elif [ "$ADD_VULNERABILITY_TESTS" = 'Y' ]
  then
    BASE_APP_URL=`cat base_apps/v3.txt`
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

  # Remove reference to the base repository
  # Skipping this step means that changes get pushed to the base repository instead of a new one.
  cd $DIR_APP && git remote remove origin

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
  cd $DIR_APP && bash mod_app.sh '01-08' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '01-09' $TOGGLE_OUTLINE
fi

##########
# ADD LINT
##########
if [ "$ADD_LINT" = 'Y' ]
then
  cd $DIR_APP && bash mod_app.sh '02-01' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '02-02' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '02-03' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '02-04' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '02-05' $TOGGLE_OUTLINE
fi

###########################
# ADD VULNERABILITY TESTING
###########################
if [ "$ADD_VULNERABILITY_TESTS" = 'Y' ]
then
  cd $DIR_APP && bash mod_app.sh '03-01' $TOGGLE_OUTLINE
  cd $DIR_APP && bash mod_app.sh '03-02' $TOGGLE_OUTLINE
fi

#########
# CLEANUP
#########
# Remove the mod* files from the new app

echo 'Cleaning up the app'
rm -rf $DIR_APP/mod
rm $DIR_APP/mod*

##########################################################################################
# FINAL TESTING (applies when Rails Neutrino is activated in the virtual environment only)
##########################################################################################
if [ "$HOST_ENV" = 'N' ]
then
  echo '---------------------'
  echo 'yarn install --silent'
  cd $DIR_APP && yarn install --silent

  echo '----------------------'
  echo 'bundle install --quiet'
  cd $DIR_APP && bundle install --quiet

  # Skip the migration until docker/migrate is provided
  if [ -f $DIR_APP/docker/migrate ]; then
    echo '---------------------------'
    echo 'bundle exec rake db:migrate'
    cd $DIR_APP && bundle exec rake db:migrate
  fi
  
  # Skip the testing if rexml is not in Gemfile.lock
  if cat Gemfile.lock | grep rexml
  then
    echo '---------------------'
    echo 'bundle exec rake test'
    cd $DIR_APP && bundle exec rake test
  fi

  # Skip RuboCop until docker/cop-auto is provided
  if [ -f $DIR_APP/docker/cop-auto ]; then
    echo '----------------------'
    echo 'bundle exec rubocop -D'
    cd $DIR_APP && bundle exec rubocop -D
  fi

  # Skip Rails Best Practices until docker/rbp is provided
  if [ -f $DIR_APP/docker/rbp ]; then
    echo '----------------------------------'
    echo 'bundle exec rails_best_practices .'
    cd $DIR_APP && bundle exec rails_best_practices .
  fi

  # Skip Brakeman until bin/brakeman is provided
  if [ -f $DIR_APP/bin/brakeman ]; then
    cd $DIR_APP && bin/brakeman
  fi

  # Skip bundler-audit until bin/audit is provided
  if [ -f $DIR_APP/bin/audit ]; then
    cd $DIR_APP && bin/audit
  fi

  echo '**********************************'
  echo 'Your new Rails app has been built!'
  echo 'Path:'
  echo "$DIR_APP"

  if [ -f $DIR_APP/docker/build ]; then
    echo 'From your HOST environment, run the "docker/build" script'
    echo 'from within the root directory of your new app.'
  fi
else
  echo 'Using the "docker/build" script to test the new app'
fi
