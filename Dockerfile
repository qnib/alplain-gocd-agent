ARG FROM_IMG_REGISTRY=docker.io
ARG FROM_IMG_TAG=":2019-02-13.1"
ARG FROM_IMG_HASH="@sha256:c85eb71442920b6ac34f65ba66a651a56b87fa060c5263df3c68fa6cd23b7a84"

FROM golang:alpine AS build
WORKDIR /go/src/github.com/estesp
RUN apk --update add git gcc musl-dev \
 && git clone https://github.com/estesp/manifest-tool.git manifest-tool
WORKDIR /go/src/github.com/estesp/manifest-tool
RUN go build

FROM ${FROM_IMG_REGISTRY}/qnib/alplain-openjre8${FROM_IMG_TAG}${FROM_IMG_HASH}

ARG GOCD_URL=https://download.gocd.io/binaries
ARG GOCD_VER=19.5.0
ARG GOCD_SUBVER=9272

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
    ENTRY_USER=gocd \
    LANG=en_US.utf8 \
    HOME_DIR=/home

# allow mounting ssh keys, dotfiles, and the go server config and data
VOLUME /godata

RUN apk add --no-cache \
   bc \
   curl \
   docker \
   file \
   gcc \
   git \
   go \
   jq \
   libffi-dev \
   linux-vanilla-dev \
   make \
   musl-dev \
   openssl \
   openssl-dev \
   perl \
   py-pip \
   python-dev \
   rsync \
   sed \
   wget \
 && pip install docker-compose \
 && rm -rf /var/cache/apk/* /tmp/* /opt/go-agent/config/autoregister.properties \
 && adduser -s /sbin/nologin -u 5000 -D -H -h /opt/go-agent/ gocd
## Allow for reusable file-system layers
RUN echo "Download '${GOCD_URL}/${GOCD_VER}-${GOCD_SUBVER}/generic/go-agent-${GOCD_VER}-${GOCD_SUBVER}.zip'" \
 && wget -qO /tmp/go-agent.zip ${GOCD_URL}/${GOCD_VER}-${GOCD_SUBVER}/generic/go-agent-${GOCD_VER}-${GOCD_SUBVER}.zip \
 && mkdir -p /opt/ && cd /opt/ \
 && unzip -q /tmp/go-agent.zip && rm -f /tmp/go-agent.zip \
 && mv /opt/go-agent-${GOCD_VER} /opt/go-agent \
 && chmod +x /opt/go-agent/agent.sh
RUN echo "Download '$(/usr/local/bin/go-github rLatestUrl --ghrepo go-dckrimg --regex \".*inux\")'" \
 && wget -qO /usr/local/bin/go-dckrimg $(/usr/local/bin/go-github rLatestUrl --ghrepo go-dckrimg --regex ".*inux") \
 && chmod +x /usr/local/bin/go-dckrimg
RUN echo "Download '$(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo service-scripts --regex ".*.tar" --limit 1)'" \
 && wget -qO - $(/usr/local/bin/go-github rLatestUrl --ghorg qnib --ghrepo service-scripts --regex ".*.tar" --limit 1) |tar xf - -C /opt/
ADD opt/qnib/gocd/agent/bin/check.sh /opt/qnib/gocd/agent/bin/
ADD opt/qnib/gocd/agent/bin/start.sh /opt/qnib/gocd/agent/bin/
COPY opt/qnib/entry/20-gocd-render-autoregister-conf.sh \
     opt/qnib/entry/30-chown-gocd-files.sh \
     opt/qnib/entry/40-unpack-bundles.sh \
     /opt/qnib/entry/
COPY opt/qnib/gocd/etc/autoregister.properties /opt/qnib/gocd/etc/
COPY --from=build /go/src/github.com/estesp/manifest-tool/manifest-tool /usr/local/bin/manifest-tool
CMD ["/opt/qnib/gocd/agent/bin/start.sh"]
