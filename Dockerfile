FROM seapy/ruby:2.1.2
MAINTAINER Open Addresses <derp@openaddress.es>

VOLUME ["/data"]

RUN apt-get update

RUN apt-get install git
RUN apt-get install -y libmysqld-dev
RUN apt-get install -y nodejs
#RUN apt-get install -y docker.io
RUN apt-get install -y libxslt1-dev
RUN apt-get install -y libxml2-dev

# Install Nginx.
RUN apt-get install -qq -y software-properties-common
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -qq -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx
# Add default nginx config
ADD config/nginx-sites.conf /etc/nginx/sites-enabled/default

# Install foreman
RUN gem install foreman

## Install MySQL(for mysql, mysql2 gem)
RUN apt-get install -qq -y libmysqlclient-dev

# Install Rails App
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install --without development test
ADD . /app

# Add default unicorn config
ADD config/unicorn.rb /app/config/unicorn.rb

# Add default foreman config
ADD Procfile /app/Procfile

RUN mkdir -p ./tmp/pids

# Make ssh dir
RUN mkdir /root/.ssh/

# Copy over private key, and set permissions
ADD ./repo-key /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/*

# Create known_hosts
RUN touch /root/.ssh/known_hosts
# Add github key
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

CMD git config --global user.email "bot@openaddress.es"
CMD git config --global user.name "Open Addresses Robot"

ENV RAILS_ENV production
CMD ./run.sh
