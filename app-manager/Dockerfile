FROM docker:dind

RUN apk --update add 'py-pip' && \
    pip install 'docker-compose'
COPY scripts/app-start.sh       /usr/local/bin/app-start
COPY scripts/app-stop.sh        /usr/local/bin/app-stop
COPY scripts/app-unique-name.sh /usr/local/bin/app-unique-name

RUN chmod a+x /usr/local/bin/*
