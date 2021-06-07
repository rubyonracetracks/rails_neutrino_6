#!/bin/bash
set -e

# AGENDA:
# * Add the docker/sandbox script for running the Rails sandbox environment (WICHTIG/LEGACY)

echo '######################################'
echo 'Unit 1 Chapter 9: Initial Test Scripts'
echo '######################################'

mv mod-01-09-docker_test docker/test
chmod +x docker/test

mv mod-01-09-docker_test_log docker/test-log
chmod +x docker/test-log

ruby mod-01-09.rb

git add .
git commit -m 'Added docker/test and docker/test-log'
