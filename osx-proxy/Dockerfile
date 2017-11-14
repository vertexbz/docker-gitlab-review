FROM alpine:3.4

COPY entrypoint /entrypoint
COPY haproxy.tmpl /etc/

RUN apk add --update --no-cache haproxy && chmod a+x /entrypoint

EXPOSE 80

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/sbin/haproxy", "-f", "/etc/haproxy.cfg"]
