#!/bin/bash
set -e

# AGENDA:
# * Add RuboCop
# * Add docker/cop script (WICHTIG/LEGACY: if necessary)

echo '############'
echo 'UNIT 2: LINT'
echo '############'

echo '################################'
echo 'Unit 2 Chapter 1: Adding RuboCop'
echo '################################'

echo 'Adding docker/cop'
mv mod-02-01-docker_cop docker/cop
chmod +x docker/cop
ruby mod-02-01.rb

git add .
git commit -m 'Added RuboCop'
