FROM alpine:3.4
MAINTAINER Ryan Schlesinger <ryan@outstand.com>

RUN apk add --no-cache bash curl syslog-ng && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    echo '2782349be167b25355537c2ce2b395e7  papertrail-bundle.tar.gz' > papertrail-bundle.md5 && \
    curl -o papertrail-bundle.tar.gz https://papertrailapp.com/tools/papertrail-bundle.tar.gz && \
    md5sum -c papertrail-bundle.md5 && \
    mkdir -p /etc/syslog-ng/cert.d && \
    cd /etc/syslog-ng/cert.d/ && \
    tar -xzf /tmp/build/papertrail-bundle.tar.gz && \
    cd /tmp && \
    rm -rf /tmp/build && \
    apk del curl

RUN mkdir /sidecar
COPY syslog-ng-source.sidecar syslog-ng-source.std syslog-ng-source.kernel syslog-ng-plugins.std /etc/syslog-ng/
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENV SYSTEM_LOGGER true
VOLUME ["/sidecar"]
CMD ["syslog-ng", "-F"]
ENTRYPOINT ["/docker-entrypoint.sh"]
