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

The sidecar version of this container disables listening on `/proc/kmsg`.  It exposes `/sidecar/log` as a unix domain logging socket (like `/dev/log`).  It is meant to be used via `--volumes-from`.

Real world example from AWS ECS:
```json
[
  {
    "name": "haproxy",
    "image": "outstand/haproxy-consul-template:latest",
    "memory": 128,
    "cpu": 100,
    "essential": true,
    "dnsServers": [
      "10.10.10.2"
    ],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      },
      {
        "containerPort": 443,
        "hostPort": 443
      },
      {
        "containerPort": 34180,
        "hostPort": 34180
      }
    ],
    "environment": [
      {
        "name": "SERVICE_NAME",
        "value": "haproxy"
      },
      {
        "name": "SERVICE_34180_IGNORE",
        "value": "true"
      },
      {
        "name": "CONSUL_HOST",
        "value": "consul"
      }
    ],
    "volumesFrom": [
      {
        "sourceContainer": "syslog-sidecar"
      }
    ]
  },
  {
    "name": "syslog-sidecar",
    "image": "outstand/syslog-ng-papertrail:sidecar",
    "memory": 50,
    "cpu": 100,
    "essential": true,
    "dnsServers": [
      "10.10.10.2"
    ],
    "environment": [
      {
        "name": "LOG_DESTINATION",
        "value": "${log_destination}"
      }
    ]
  }
]
```
