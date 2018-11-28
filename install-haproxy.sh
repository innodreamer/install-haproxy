#!/bin/bash

# Check runtime user
if [[ $EUID -ne 0 ]]; then
   echo "  This script must be run as root" 
   exit 1
fi

# Check command line argument
if [[ -z $1 ]]; then
  echo
  echo "  Please specify haproxy version in command line."
  echo
  echo "  usage:     sudo $0 \${VERSION}"
  echo
  echo "  example:   sudo $0 1.8.14"
  echo
  exit 1
fi

# script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# haproxy version
VERSION=$1
# haproxy branch
BRANCH=$(echo $VERSION | cut -d. -f1,2)
# haproxy installation directory
PREFIX=/opt/haproxy-${VERSION}
# haproxy source code tar.gz file name
SRCTGZ=haproxy-${VERSION}.tar.gz
# temporary directory
TMPDIR=/tmp/haproxy-${VERSION}-build

# download source code
if [ ! -f haproxy-${VERSION}.tar.gz ]; then
  wget http://www.haproxy.org/download/${BRANCH}/src/haproxy-${VERSION}.tar.gz
fi

# create temporary directory
echo "Temporary Directory: ${TMPDIR}"
mkdir -p ${TMPDIR}
# create target directory
if [ -e ${PREFIX} ]; then
  rm -rf ${PREFIX}
fi
echo "Target Directory: ${PREFIX}"
mkdir -p ${PREFIX}
# copy files
cp ${SRCTGZ} ${TMPDIR}
cp haproxy.service ${TMPDIR}
# change to temporary directory
cd ${TMPDIR}
# decompress
tar xzf ${SRCTGZ}
# change into source code directory
cd haproxy-${VERSION}

# build haproxy
echo "Start building haproxy..."
echo
make \
    TARGET=linux2628 USE_LINUX_TPROXY=1 USE_ZLIB=1 USE_REGPARM=1 USE_PCRE=1 USE_PCRE_JIT=1 \
    USE_OPENSSL=1 SSL_INC=/usr/include SSL_LIB=/usr/lib ADDLIB=-ldl \
    CFLAGS="-O2 -g -fno-strict-aliasing -DTCP_USER_TIMEOUT=18" \
    PREFIX=${PREFIX}
echo
# install haproxy
echo "Install haproxy to target directory..."
echo
make install PREFIX=${PREFIX}
echo "Done."

# set up systemd service
echo "Set up systemd service..."
cd ${TMPDIR}
sed "s+{HAPROXY_PREFIX}+${PREFIX}+g" haproxy.service > /etc/systemd/system/haproxy.service
echo "Done."

cd $DIR
# remove temporary directory
rm -rf $TMPDIR
echo "Temporary directory removed."
