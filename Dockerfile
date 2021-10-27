# BASED ON
# https://blog.codeminer42.com/zero-to-up-and-running-a-rails-project-only-using-docker-20467e15f1be/

# Specify the Docker image to use as a base:
FROM registry.gitlab.com/rubyonracetracks/docker-debian-bullseye-rvm-rails-neutrino6

ENV DEBIAN_FRONTEND=noninteractive

COPY ./ /home/winner/neutrino/

RUN sudo chown -R winner:winner /home/winner/neutrino && \
    cd /home/winner/neutrino && bash build-rails.sh
