FROM ubuntu:14.04
MAINTAINER Jason Wieringa <jasonwieringa@gmail.com>

ENV BUNDLE_JOBS=2
ENV APP_DIR /opt/app

RUN apt-get update && apt-get install -y \
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

COPY Gemfile $APP_DIR/Gemfile
COPY Gemfile.lock $APP_DIR/Gemfile.lock

WORKDIR $APP_DIR

RUN bundle config build.nokogiri --with-xml2-include=/usr/include/libxml2 \
      && /usr/bin/bundle install

COPY . $APP_DIR
COPY contrib/templates/database.yml $APP_DIR/config/database.yml

ENTRYPOINT ["/opt/app/contrib/scripts/docker-entrypoint.sh"]
