# GitLab review apps via Docker

### `!!` Before running on OSX look at comments in `docker-compose.yml`


## Deploy proof of concept environment

### Quick start
To easily deploy environment use command below and follow instructions, probably with `sudo` on linux
```
sh start.sh
```


### Manual setup

- Build app-manager
```
cd app-manager
docker build -t app-manager:latest .
cd ..
```

- Run stack
```
docker-compose up -d
```

- Configure DNS
    - **macOS**: add `127.0.0.1` to dns servers, on top of list  (System Preferences -> Network -> Advanced -> DNS)
    - **Linux**: add `10.223.223.3` to top of `resolv.conf` or to dnsmasq configuration (for dnsmasq consider also **strict-order** and **no-negcache** options)

- GitLab address is http://gitlab.dev

- Log in and navigate to http://gitlab.dev/admin/runners for global runner registration token

- Register runner (replace `REGISTRATION_TOKEN` with valid ci token)
```
docker-compose exec gitlab-runner gitlab-ci-multi-runner register \
                     --non-interactive \
                     --url "http://gitlab-ci/" \
                     --registration-token "REGISTRATION_TOKEN" \
                     --description "gitlab-review-app-manager" \
                     --tag-list "app-manager" \
                     --executor "docker" \
                     --docker-image "app-manager" \
                     --docker-privileged true \
                     --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
                     --docker-extra-hosts "gitlab.dev:10.223.223.2" \
                     --docker-pull-policy "if-not-present"
```

- Set following to `runner-config/config.toml` in section `[runners.docker]` of `gitlab-review-app-manager` (be carefull, there can be duplicates - in this case you have to merge configs by your self)
```
    privileged = true
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    extra_hosts = ["gitlab.dev:10.223.223.2"]
    pull_policy = "if-not-present"
```


## Create project and Review it

- Create project for `example-app` directory contents in GitLab, commit and push it there (instructions available on project site)

- Go to `CI / CD` / `Pipelines` when test finish you can start the review environment clicking play button on `Start Review` job

- When deploy is done, you should link to deployment information above pipeline output, go to this page

- Finally, the `View deployment` button takes you to just deployed review environment, `Stop` button stops the instance


## Known issues

- Mapping local files to volumes for review environment is not supported (yet)


## Links

- Docker Compose
    - https://docs.docker.com/compose/overview/
    - https://docs.docker.com/compose/compose-file/#variable-substitution
- docker-gen
    - https://github.com/jwilder/docker-gen
- HAProxy
    - http://www.haproxy.org/
    - http://cbonte.github.io/haproxy-dconv/1.7/intro.html
    - http://cbonte.github.io/haproxy-dconv/1.7/configuration.html
- dnsmasq
    - http://www.thekelleys.org.uk/dnsmasq/doc.html
    - http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
- docker
    - https://medium.com/lucjuggery/about-var-run-docker-sock-3bfd276e12fd
- GitLab
    - https://docs.gitlab.com/runner/
    - https://docs.gitlab.com/runner/register/index.html#docker
    - https://github.com/ayufan/gitlab-ci-multi-runner/blob/master/docs/configuration/advanced-configuration.md
    - https://github.com/ayufan/gitlab-ci-multi-runner/blob/master/docs/commands/README.md
    - https://docs.gitlab.com/ce/ci/README.html
    - https://docs.gitlab.com/ce/ci/environments.html
