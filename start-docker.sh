#!/bin/bash
set -e

docker run -i -t --rm -v ${PWD}:/home/winner/neutrino registry.gitlab.com/rubyonracetracks/docker-debian-bullseye-rvm-rails-neutrino6 /home/winner/neutrino/start-build-rails
