#!/bin/bash

# Wait until postgres is ready
while ! pg_isready -q -h $POSTGRES_HOSTNAME -p $POSTGRES_PORT -U $POSTGRES_USERNAME
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $POSTGRES_DATABASE"` ]]; then
  echo "Database $POSTGRES_DATABASE does not exist. Creating..."
  createdb -E UTF8 $POSTGRES_DATABASE -l en_US.UTF-8 -T template0
  mix ecto.migrate
  mix run priv/repo/seeds.exs
  echo "Database $POSTGRES_DATABASE created."
fi

exec mix phx.server