web: bundle exec unicorn -c config/unicorn.rb
nginx: /usr/sbin/nginx -c /etc/nginx/nginx.conf
worker: bundle exec dotenv rake resque:restart_daemons
