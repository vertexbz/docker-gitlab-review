#!/bin/sh

exec docker-compose -p "`app-unique-name`" down -v
