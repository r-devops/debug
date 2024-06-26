#!/bin/bash

# To build podman, you have enough resource on the instance.
# I tested this script on t2.xlarge.

topdir=${HOME}/work
mkdir -p ${topdir}

# Install prereq rpms
dnf install -y git golang libseccomp-devel gpgme-devel autoconf automake libtool yajl yajl-devel libcap-devel systemd-devel cni-plugins iptables-nft rpm-build meson golang-github-cpuguy83-md2man.x86_64

# Build podman
echo "=> Building podman..."
cd ${topdir}
git clone https://github.com/containers/podman
cd podman
git switch v4.5
make
make install

# Build conmon
echo "=> Building conmon..."
cd ${topdir}
git clone https://github.com/containers/conmon
cd conmon
make -j
make install

# Build crun
echo "=> Building crun..."
cd ${topdir}
git clone https://github.com/containers/crun
cd crun
./autogen.sh
./configure --prefix=/usr/local
make -j
make install

# Build libslirp
echo "=> Building libslirp..."
cd ${topdir}
git clone https://gitlab.freedesktop.org/slirp/libslirp.git
cd libslirp
git switch stable-4.2
meson build
ninja -C build
ninja -C build install

# Build slirp4netns
echo "=> Building slirp4netns..."
cd ${topdir}
git clone https://github.com/rootless-containers/slirp4netns.git
cd slirp4netns
git switch release/0.4
./autogen.sh
./configure --prefix=/usr/local
make -j
make install

# Install containers-common
echo "=> Building containers-common..."
mkdir ${topdir}/Downloads
cd ${topdir}/Downloads
yum install -y https://rpmfind.net/linux/fedora/linux/updates/39/Everything/x86_64/Packages/c/containers-common-1-99.fc39.noarch.rpm

ln -s /usr/local/bin/podman /usr/local/bin/docker
