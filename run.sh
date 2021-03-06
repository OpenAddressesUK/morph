#!/bin/sh

bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake assets:precompile
bundle exec rake app:update_docker_image
bundle exec rake resque:restart_daemons
foreman start -f Procfile
