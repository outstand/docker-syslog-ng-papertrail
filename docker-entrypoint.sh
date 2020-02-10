#!/bin/bash

set -x

if [ -z "$LOG_DESTINATION" ]; then
  echo 'LOG_DESTINATION required'
  exit 1
fi

if [ "$1" == 'rsyslogd' ]; then
  echo 'Replacing rsyslogd command with syslog-ng -F'
  set -- syslog-ng -F
fi

if [ -e /host/dev ]; then
    mount --rbind /host/dev /dev
fi

CA_BASE=/etc/ssl/certs/ca-certificates.crt.rancher
CA=/etc/ssl/certs/ca-certificates.crt

if [[ -e ${CA_BASE} && ! -e ${CA} ]]; then
    cp $CA_BASE $CA
fi

IFS=':' read -r host port <<< "${LOG_DESTINATION}"
echo Host: ${host}
echo Port: ${port}

cat > /etc/syslog-ng/conf.d/papertrail.conf <<EOM
destination d_papertrail {
  network(
    "${host}"
    port(${port})
    transport("tls")
    tls(ca_dir("/etc/syslog-ng/cert.d"))
  );
};
log { source(s_all); destination(d_papertrail); };
EOM

echo Starting "$@"
exec "$@"
