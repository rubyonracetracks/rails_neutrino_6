#!/bin/bash
set -e

# AGENDA:
# * Add the docker/test and docker/test-log scripts for running the test suite
# * Add the docker/git_check script to run before executing "git add" and "git commit"

echo '######################################'
echo 'Unit 1 Chapter 9: Initial Test Scripts'
echo '######################################'

mv mod-01-09-docker_test docker/test
chmod +x docker/test

mv mod-01-09-docker_test_log docker/test-log
chmod +x docker/test-log

mv mod-01-09-docker_git_check docker/git_check
chmod +x docker/git_check

ruby mod-01-09.rb

git add .
git commit -m 'Added docker/test and docker/test-log'
