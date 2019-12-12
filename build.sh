#!/bin/sh

# This should be ran as root, preferably in a chroot or a container

apt update
apt install ca-certificates git debhelper nodejs npm python python3-setuptools devscripts fakeroot git-lfs build-essential --no-install-recommends -y
git clone --depth 1 https://github.com/mozilla-iot/gateway-deb.git
git lfs pull
tar xf webthings-gateway*
cp -r debian gateway-*
cd gateway-*
npm i -g npm
ln -fs /usr/local/bin/npm /usr/bin/npm
debuild -us -uc
