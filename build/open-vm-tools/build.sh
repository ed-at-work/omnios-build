#!/usr/bin/bash
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright (c) 2014 by Delphix. All rights reserved.
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
#

# Load support functions
. ../../lib/functions.sh

PROG=open-vm-tools
VER=10.1.15
PKG=system/virtualization/open-vm-tools
SUMMARY="Open Virtual Machine Tools"
DESC="The Open Virtual Machine Tools project aims to provide a suite of open source virtualization utilities and drivers to improve the functionality and user experience of virtualization. The project currently runs in guest operating systems under the VMware hypervisor."

PATH=/usr/gnu/bin:$PATH export PATH

BUILD_DEPENDS_IPS='developer/pkg-config'
RUN_DEPENDS_IPS='system/library/gcc-5-runtime'

# _FILE_OFFSET_BITS=64 - Large file interface is required
# _XPG4_2 - Need cmsg from UNIX95
# __EXTENSIONS__ - Need gethostbyname_r in _XPG4_2

CFLAGS="\
	-std=gnu89 \
	-Wno-logical-not-parentheses \
	-Wno-bool-compare \
	-Wno-deprecated-declarations \
	-Wno-unused-local-typedefs \
	-D_FILE_OFFSET_BITS=64 \
	-D_XPG4_2 \
	-D__EXTENSIONS__ \
"
CONFIGURE_OPTS="
	--without-kernel-modules
	--disable-static
	--disable-multimon
	--without-x
	--without-dnet
	--without-icu
	--without-gtk2
	--without-gtkmm
	--enable-deploypkg=no
	--disable-grabbitmqproxy
	--without-xerces
	--disable-docs
"

# There's some hand assembly in here that only works in 32-bit
BUILDARCH=32

# Parts of the vmbackup code get generated by 'rpcgen' which adds unused
# variables. Disable -Werror for this directory.
make_prog32() {
	sed -i 's/-Werror//g' services/plugins/vmbackup/Makefile
	make_prog
}

install_conf() {
	pushd $DESTDIR > /dev/null
	mkdir -p etc/vmware-tools/
	cp $SRCDIR/files/tools.conf etc/vmware-tools/
	popd > /dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
export LIBS="-lnsl"
build
install_smf system/virtualization open-vm-tools.xml
install_conf
make_isa_stub
make_package
clean_up
