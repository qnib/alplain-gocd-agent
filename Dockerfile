ARG DOCKER_REG=docker.io
FROM ${DOCKER_REG}/qnib/alplain-openjre8:edge

ARG GOCD_URL=https://download.gocd.io/binaries
ENV GO_SERVER_URL=https://tasks.server:8154/go \
    GOCD_LOCAL_DOCKERENGINE=false \
    GOCD_CLEAN_IMAGES=false \
    DOCKER_TAG_REV=true \
    GOCD_AGENT_AUTOENABLE_KEY=qnibFTW \
    GOCD_AGENT_AUTOENABLE_ENV=latest,upstream,docker,deploy \
    GOCD_AGENT_AUTOENABLE_RESOURCES=alpine \
    DOCKER_REPO_DEFAULT=qnib \
    GOPATH=/usr/local/ \
    DOCKER_CONSUL_DNS=false \
    ENTRYPOINTS_DIR=/opt/qnib/entry/ \
    LANG=en_US.utf8

# allow mounting ssh keys, dotfiles, and the go server config and data
VOLUME /godata

RUN apk add --no-cache wget git jq perl sed bc curl go linux-vanilla-dev gcc openssl make file py-pip rsync \
 && wget -qO /usr/local/bin/docker  https://github.com/ChristianKniep/docker/releases/download/v17.05.0-ce/docker-17.05.0-ce \
 && chmod +x /usr/local/bin/docker \
 && pip install docker-compose \
 && wget -qO /usr/local/bin/go-github https://github.com/qnib/go-github/releases/download/0.2.2/go-github_0.2.2_MuslLinux \
 && chmod +x /usr/local/bin/go-github \
 && echo "Download '$(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo service-scripts --regex ".*.tar" --limit 1)'" \
 && wget -qO - $(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo service-scripts --regex ".*.tar" --limit 1) |tar xf - -C /opt/ \
 && wget -qO /usr/local/bin/go-dckrimg $(/usr/local/bin/go-github rLatestUrl --ghrepo go-dckrimg --regex ".*inux") \
 && chmod +x /usr/local/bin/go-dckrimg \
 && rm -f /usr/local/bin/go-github \
 && rm -rf /var/cache/apk/* /tmp/* /usr/local/bin/go-github /opt/go-agent/config/autoregister.properties \
 && . /opt/service-scripts/gocd/common/version \
 && wget -qO /tmp/go-agent.zip ${GOCD_URL}/${GOCD_VER}-${GOCD_SUBVER}/generic/go-agent-${GOCD_VER}-${GOCD_SUBVER}.zip \
 && mkdir -p /opt/ && cd /opt/ \
 && unzip -q /tmp/go-agent.zip && rm -f /tmp/go-agent.zip \
 && mv /opt/go-agent-${GOCD_VER} /opt/go-agent \
 && chmod +x /opt/go-agent/agent.sh
COPY opt/qnib/gocd/agent/bin/check.sh \
     opt/qnib/gocd/agent/bin/start.sh \
     /opt/qnib/gocd/agent/bin/
COPY opt/qnib/entry/20-gocd-render-autoregister-conf.sh \
     opt/qnib/entry/30-chown-gocd-files.sh \
     /opt/qnib/entry/
COPY opt/qnib/gocd/etc/autoregister.properties /opt/qnib/gocd/etc/
RUN adduser -s /sbin/nologin  -D -H -h /opt/go-agent/ gocd
CMD ["/opt/qnib/gocd/agent/bin/start.sh"]
