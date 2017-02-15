#!/bin/bash

if [ -z "$LOG_DESTINATION" ]; then
  echo 'LOG_DESTINATION required'
  exit 1
fi

if [ "$1" == 'rsyslogd']; then
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

# The following two methods are ripped from alpine's syslog-ng package.
# This allows us (and a user) to customize the config with snippets.
grep_syslog_conf_entries() {
  local section="$1" FN filelist
  grep -v '^#' /etc/syslog-ng/syslog-ng-${section}.std
  filelist=$(find /etc/syslog-ng/ -maxdepth 1 -type f -name "syslog-ng-${section}.*" | grep -Ev ".backup|.std|~")
  if [ $? -eq 0 ]
  then
    for FN in ${filelist}
    do
      grep -v '^#' $FN
    done
  fi
}

update() {
  local fname='/etc/syslog-ng/syslog-ng.conf'
  local f_tmp="/etc/syslog-ng/syslog-ng.conf.$$"
  for ng_std in options source destination filter log
  do
    [ -f /etc/syslog-ng/syslog-ng-${ng_std}.std ] || exit 1
  done
  {
    # create options entries
    grep_syslog_conf_entries plugins
    echo "options {"
    grep_syslog_conf_entries options
    echo "};"
    # create source entries
    echo "source s_all {"
    grep_syslog_conf_entries source
    echo "};"
    # create destination entries
    grep_syslog_conf_entries destination
    # create filter entries
    grep_syslog_conf_entries filter
    # create log entries
    grep_syslog_conf_entries log
  } > $f_tmp
  cp -p $f_tmp $fname
  rm -f $f_tmp
}

if [ "${SYSTEM_LOGGER}" != "true" ]; then
  # Disable reading from /proc/kmsg
  rm /etc/syslog-ng/syslog-ng-source.kernel
fi

update

IFS=':' read -r host port <<< "${LOG_DESTINATION}"
echo Host: ${host}
echo Port: ${port}

cat >> /etc/syslog-ng/syslog-ng.conf <<EOM
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
