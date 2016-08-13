#!/bin/bash

waitForDb () {
  until nc -z postgres 5432; do
    logger -s -t docker-entrypoint "waiting for postgres..."
    sleep 2
  done
}

if [ "$1" = 'snapfresh' ]; then
  waitForDb
  bundle exec bin/rake db:create
  bundle exec bin/rake db:migrate
  bundle exec bin/rake assets:precompile
  bundle exec bin/rake db:datarefresh
  exec /usr/sbin/apache2ctl -D FOREGROUND
fi

if [ "$1" = 'test' ]; then
  waitForDb
  bundle exec bin/rake db:create
  bundle exec bin/rake db:migrate
  exec bundle exec bin/rake test
fi

exec "$@"
