ARG DOCKER_REGISTRY=docker.io
ARG DOCKER_IMG_TAG=":3.6"
ARG DOCKER_IMG_HASH="@sha256:dc4fefaee33ec5afb8cfa3730b53d2116bfe874cce1e621065aa1755eaf4bb64"
FROM ${DOCKER_REGISTRY}/qnib/alplain-openjre8${DOCKER_IMG_TAG}${DOCKER_IMG_HASH}

ARG GOCD_URL=https://download.gocd.io/binaries
ARG GOCD_VER=17.9.0
ARG GOCD_SUBVER=5368
ENV GO_SERVER=gocd-server \
    GOCD_LOCAL_DOCKERENGINE=false \
    GOCD_CLEAN_IMAGES=false \
    DOCKER_TAG_REV=true \
    GOCD_AGENT_AUTOENABLE_KEY=qnibFTW \
    GOCD_AGENT_AUTOENABLE_ENV=latest,upstream,docker,deploy \
    GOCD_AGENT_AUTOENABLE_RESOURCES=alpine \
    DOCKER_REPO_DEFAULT=qnib \
    GOPATH=/usr/local/ \
    DOCKER_CONSUL_DNS=false \
    ENTRYPOINTS_DIR=/opt/qnib/entry
RUN apk add --no-cache wget git jq perl sed bc curl go linux-vanilla-dev gcc openssl make file py-pip docker \
 && go get cmd/vet \
 && pip install docker-compose \
 && wget -qO /usr/local/bin/go-github https://github.com/qnib/go-github/releases/download/0.2.2/go-github_0.2.2_MuslLinux \
 && chmod +x /usr/local/bin/go-github \
 && echo "Download '$(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo service-scripts --regex ".*.tar" --limit 1)'" \
 && wget -qO - $(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo service-scripts --regex ".*.tar" --limit 1) |tar xf - -C /opt/ \
 && wget -qO /usr/local/bin/go-dckrimg $(/usr/local/bin/go-github rLatestUrl --ghrepo go-dckrimg --regex ".*inux") \
 && chmod +x /usr/local/bin/go-dckrimg \
 && rm -f /usr/local/bin/go-github \
 && rm -rf /var/cache/apk/* /tmp/* /usr/local/bin/go-github /opt/go-agent/config/autoregister.properties \
 && wget -qO /tmp/go-agent.zip ${GOCD_URL}/${GOCD_VER}-${GOCD_SUBVER}/generic/go-agent-${GOCD_VER}-${GOCD_SUBVER}.zip \
 && mkdir -p /opt/ && cd /opt/ \
 && unzip -q /tmp/go-agent.zip && rm -f /tmp/go-agent.zip \
 && mv /opt/go-agent-${GOCD_VER} /opt/go-agent
RUN chmod +x /opt/go-agent/agent.sh
ADD opt/qnib/gocd/agent/bin/check.sh \
    opt/qnib/gocd/agent/bin/start.sh \
    /opt/qnib/gocd/agent/bin/
ADD opt/qnib/entry/20-gocd-render-autoregister-conf.sh /opt/qnib/entry/
ADD opt/qnib/gocd/etc/autoregister.properties /opt/qnib/gocd/etc/
CMD ["/opt/qnib/gocd/agent/bin/start.sh"]
