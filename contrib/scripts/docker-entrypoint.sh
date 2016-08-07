#!/bin/bash

if [ "$1" = 'snapfresh' ]; then

  until nc -z postgres 5432; do
    logger -s -t docker-entrypoint "waiting for postgres..."
    sleep 2
  done

  bundle exec bin/rake db:create
  bundle exec bin/rake db:migrate
  bundle exec bin/rake assets:precompile
  bundle exec bin/rake db:datarefresh
  exec /usr/sbin/apache2ctl -D FOREGROUND
fi

exec "$@"
