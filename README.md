# Supported tags and respective `Dockerfile` links

- [`latest`, (*Dockerfile*)](https://github.com/outstand/docker-syslog-ng-papertrail/blob/master/Dockerfile)
- [`sidecar`, (*Dockerfile.sidecar*)](https://github.com/outstand/docker-syslog-ng-papertrail/blob/master/Dockerfile.sidecar)

# Usage

```yaml
syslog:
  image: outstand/syslog-ng-papertrail:latest
  labels:
    io.rancher.os.scope: system
  log_driver: json-file
  net: host
  privileged: true
  restart: always
  uts: host
  volumes_from:
  - system-volumes
  environment:
    - LOG_DESTINATION=${log_destination}
```
