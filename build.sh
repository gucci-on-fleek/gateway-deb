#!/bin/bash

set -e

# This should be ran as root, preferably in a chroot or a container

# Install build dependencies
apt update
apt install ca-certificates git debhelper nodejs npm python python3-setuptools devscripts fakeroot git-lfs build-essential python3-pip libnanomsg-dev libffi-dev libpython3-dev --no-install-recommends -y

# The default system npm tends to be really buggy
npm i -g npm@latest
ln -fs /usr/local/bin/npm /usr/bin/npm

git clone --depth 1 https://github.com/gucci-on-fleek/gateway-deb.git
cd gateway-deb

# Unpack the tarball
git lfs pull
tar xzf *.orig.tar.gz
cd webthings-gateway

# Copy in the build scripts
cp -r ../debian .

# Pin the node major version, since dependencies will be built against it
_node_version=$(dpkg --status nodejs | awk '/Version/ {print $2}' | cut -d. -f1)
sed -i "s/{{nodejs}}/nodejs (>= ${_node_version}.0.0), nodejs (<< $(expr ${_node_version} + 1).0.0~~)/" debian/control

# Pin the python3 major version, since dependencies will be built against it
_python3_version=$(dpkg --status python3 | awk '/Version/ {print $2}' | cut -d. -f 1-2)
sed -i "s/{{python3}}/python3 (>= ${_python3_version}.0), python3 (<< 3.$(expr $(echo ${_python3_version} | cut -d. -f2) + 1).0~~)/" debian/control

npm config set unsafe-perm true
npm install

# Build it
debuild -us -uc

# Done building, let's just rename things
cd ..
_deb=$(ls webthings-gateway_*.deb)
_renamed="${_deb/.deb/-$(lsb_release -is | tr '[A-Z]' '[a-z]')-$(lsb_release -cs | tr '[A-Z]' '[a-z]')}.deb"
mv "${_deb}" "${_renamed}"
ln -s "${_renamed}" "webthings-gateway.deb"

echo ""
echo "Done building: ${_renamed}"
