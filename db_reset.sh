#!/bin/sh


mix ecto.drop
mix ecto.create

psql -d CxsStarterWeb_dev -c "CREATE EXTENSION citext;"


mix ecto.rollback --all
mix ecto.migrate
mix run priv/repo/seeds.exs

MIX_ENV=test mix ecto.drop
MIX_ENV=test mix ecto.create

psql -d CxsStarterWeb_test -c "CREATE EXTENSION citext;"

MIX_ENV=test mix ecto.rollback --all
MIX_ENV=test mix ecto.migrate
MIX_ENV=test mix run priv/repo/seeds.exs