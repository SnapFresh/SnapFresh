# This is used for testing, not intended for production systems.
# Production versions as of 08/2015
#   + Ubuntu 14.04.02
#   + Ruby 1.9.3p484
#   + Passenger + Apache

FROM ubuntu:14.04
MAINTAINER Jason Wieringa <jasonwieringa@gmail.com>

ENV RAILS_ENV=production
ENV BUNDLE_JOBS=2
ENV APP_DIR /opt/app

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 \
      && apt-get update \
      && apt-get install -y \
      apt-transport-https \
      ca-certificates \
      && echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list

RUN apt-get update && apt-get install -y \
      libapache2-mod-passenger \
      apache2-mpm-worker \
      libxml2-dev \
      libxslt-dev \
      zlib1g-dev \
      libpq-dev \
      patch \
      make \
      gcc \
      g++ \
      ruby \
      ruby-dev \
      bundler \
      postgresql-client-9.3 \
      wget \
      unzip \
      --no-install-recommends \
      && rm -rf /var/lib/apt/lists/*

RUN /usr/bin/ruby1.9.1 /usr/bin/passenger-install-apache2-module --apxs2-path='/usr/bin/apxs'

COPY Gemfile $APP_DIR/Gemfile
COPY Gemfile.lock $APP_DIR/Gemfile.lock

WORKDIR $APP_DIR

RUN bundle config build.nokogiri --with-xml2-include=/usr/include/libxml2 \
      && /usr/bin/bundle install --without test development debug doc

COPY . $APP_DIR
COPY contrib/templates/database.yml $APP_DIR/config/database.yml

# Apache configurations
COPY contrib/templates/apache.conf /etc/apache2/sites-enabled/allincomefoods.conf
RUN chown -R www-data:www-data $APP_DIR
RUN echo "ServerName localhost" | sudo tee /etc/apache2/conf-enabled/fqdn.conf
RUN ln -sf /dev/stdout /var/log/apache2/access.log
RUN ln -sf /dev/stderr /var/log/apache2/error.log

ENTRYPOINT ["/opt/app/contrib/scripts/docker-entrypoint.sh"]
