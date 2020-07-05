# base image
FROM postgres:11.2-alpine

ENV bust_cach="e"

# run create.sql on init
ADD create.sql /docker-entrypoint-initdb.d
