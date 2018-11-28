# install-haproxy
Bash script to install haproxy

## Before you start

Install dependencies:

```bash
yum upgrade -y
yum install -y make gcc perl pcre-devel zlib-devel openssl-devel
```

If networking on your server is not good, save `haproxy-${VERSION}.tar.gz` to the same directory which the script is located.

## Install haproxy

```bash
sudo ./install-haproxy.sh ${VERSION}
```

e.g. `sudo ./install-haproxy.sh 1.8.14`

## After installation

You may need to reload systemd:

```bash
systemctl daemon-reload
```
