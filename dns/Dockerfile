FROM alpine:3.4

ENV DOCKER_GEN_VERSION=0.7.3


COPY entrypoint /entrypoint
COPY docker-gen.cfg dnsmasq.tmpl /etc/docker-gen/

RUN apk add --update --no-cache dnsmasq wget gzip && mkdir /etc/pre-run.d/ && chmod a+x /entrypoint && \
    wget --no-check-certificate "http://www.github.com/jwilder/docker-gen/releases/download/${DOCKER_GEN_VERSION}/docker-gen-linux-amd64-${DOCKER_GEN_VERSION}.tar.gz" -O /gen.tar.gz && \
    gunzip gen.tar.gz && apk del --purge wget gzip && tar xf gen.tar && rm gen.tar && mv docker-gen /usr/bin/ && \
    echo "user=root" >> /etc/dnsmasq.conf

EXPOSE 53/udp

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/bin/docker-gen","-config","/etc/docker-gen/docker-gen.cfg"]

