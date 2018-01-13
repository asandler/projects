#!/bin/bash

#su - postgres
#/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
sudo killall postgres
sudo mkdir -p /var/run/postgresql
sudo chown postgres /var/run/postgresql/
su -c "/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data >/home/postgres/logfile 2>&1 &" -s /bin/sh postgres
#/usr/local/pgsql/bin/createdb test
#/usr/local/pgsql/bin/psql test

ps aux | grep postgres

rm -r tmp/
rm -r public/assets
if [ "$1" == "prod" ]; then
    RAILS_ENV=production bundle exec rake assets:clean assets:precompile
    bin/rails server -e production -b 178.57.217.165
else
    rake assets:clean assets:precompile
    bin/rails server
fi
