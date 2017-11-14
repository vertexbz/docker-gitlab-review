#!/bin/sh

app-stop 2 > /dev/null > /dev/null
docker-compose build
exec docker-compose -p "`app-unique-name`" up -d
