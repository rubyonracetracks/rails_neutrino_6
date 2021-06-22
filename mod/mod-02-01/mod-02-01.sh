#!/bin/bash
set -e

# AGENDA:
# * Add the docker/sandbox script for running the Rails sandbox environment (WICHTIG/LEGACY)

echo '############'
echo 'UNIT 2: LINT'
echo '############'

echo '################################'
echo 'Unit 2 Chapter 1: Adding RuboCop'
echo '################################'

ruby mod-02-01.rb

git add .
git commit -m 'Added RuboCop'
