# DNS
```sh
docker run -v /var/run/docker.sock:/var/run/docker.sock:ro -d -p 53:53/udp -p 80:80 --name dns <this-image>
```
Option to override forwarded dns servers via environment variable `CUSTOM_FALLBACK_DNS` with comma separated nameservers

`FALLBACK_DNS="192.168.20.2,8.8.8.8,8.8.4.4"`

Option to change returned ip for queries (default is actual container's ip in docker virtual network) via environment variable `DNS_IP`
- `DNS_IP="self"` - always return ip of dns container in docker virtual network
- `DNS_IP="127.0.0.1"` - always return 127.0.0.1

# Run
- Run one of proxy containers
- Configure 127.0.0.1 as nameserver
- Run container with VHOST environment variable with desired hostname
- ping (or whatever) the hostname
