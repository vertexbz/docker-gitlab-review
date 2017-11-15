#!/bin/bash

# setup
IS_MAC_OS=[ "`uname`" -eq "Darwin" ]

if $IS_MAC_OS; then
    sed -i.bak "s/^##//g" ./docker-compose.yml
    rm -f ./docker-compose.yml.bak
fi

DIR=`pwd`

# some shiny stuff
function color { #(bg, fg, text, effect) # Effects: 7 - reverse, 4 - underline, 1 - bold
    printf '\e[%d;%d;%dm%s\e[m' $4 $2 $1 "$3"
}

function perror {
    echo
    color 49 31 "$@" 1
    echo
    echo
}

function pprompt {
    color 49 34 "$@" 1
}

function pinfo {
    color 49 33 "$@" 0
    echo
}

function psuccess {
    color 49 32 "$@" 1
    echo
}

function pinstruct {
    echo
    color 49 39 "$@" 1
    echo
    echo
}

# go!

# build local app-manager image
pinfo "Build local app-manager image..."
cd $DIR/app-manager
docker build -t app-manager:latest .
if [ $? -ne 0 ]; then
    perror "ERROR! Couldn't build app-manager image!"
    exit 1
fi


# deploy environment
pinfo "Deploy environment..."
cd $DIR
docker-compose up -d
if [ $? -ne 0 ]; then
    perror "ERROR! Couldn't deploy!"
    exit 1
fi

if $IS_MAC_OS; then
    pinstruct "Please add 127.0.0.1 to dns servers, on top of list (System Preferences -> Network -> Advanced -> DNS)."
else
    pinstruct "Please add 10.223.223.3 to top of resolv.conf or to dnsmasq configuration (for dnsmasq consider also strict-order and no-negcache options)."
fi

pprompt "Hit enter when it's done..."
read

pinfo "GitLab address is http://gitlab.dev (first start takes a few minutes)."
pinstruct "Login and navigate to http://gitlab.dev/admin/runners for global runner registration token."

# register app-manager runner
pinfo "Register app-manager runner..."
pprompt "Enter runner registration token: "
read RUNNER_REGISTARTION_TOKEN

docker-compose exec gitlab-runner gitlab-ci-multi-runner register \
                     --non-interactive \
                     --url "http://gitlab-ci/" \
                     --registration-token "$RUNNER_REGISTARTION_TOKEN" \
                     --description "gitlab-review-app-manager" \
                     --tag-list "app-manager" \
                     --executor "docker" \
                     --docker-image "app-manager" \
                     --docker-privileged true \
                     --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
                     --docker-extra-hosts "gitlab.dev:127.0.0.1" \
                     --docker-pull-policy "if-not-present" \
                     --docker-network-mode "host"

if [ $? -ne 0 ]; then
    perror "ERROR! Couldn't register CI runner!"
    exit 1
fi

RUNNERS=`grep "\[\[runners]]" ./runner-config/config.toml | wc -l | grep -o "[0-9]"`
RUNNER_TOKEN=`grep token ./runner-config/config.toml | cut -d '"' -f 2`

if [ $RUNNERS == 1 -a ${#RUNNER_TOKEN} > 10 ]; then
pinfo "Adjusting runner-config/config.toml config."
cat > ./runner-config/config.toml <<EOF
concurrent = 1
check_interval = 0

[[runners]]
  name = "gitlab-review-app-manager"
  url = "http://gitlab-ci/"
  token = "$RUNNER_TOKEN"
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "app-manager"
    privileged = true
    disable_cache = false
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    extra_hosts = ["gitlab.dev:127.0.0.1"]
    network_mode= "host"
    pull_policy = "if-not-present"
    shm_size = 0
  [runners.cache]

EOF
fi

psuccess "DONE!"
