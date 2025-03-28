#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}
#
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=mosquitto
VER=2.0.20
PKG=ooce/network/mosquitto
SUMMARY="$PROG - an open source message broker"
DESC="$PROG is an open source (EPL/EDL licensed) message broker that "
DESC+="implements the MQTT protocol versions 5.0, 3.1.1 and 3.1."

forgo_isaexec
test_relver '>=' 151053 && set_clangver
set_standard XPG7 CFLAGS

OPREFIX=$PREFIX
PREFIX+=/$PROG

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
"

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DUSER=mosquitto -DUID=73
    -DGROUP=mosquitto -DGID=73
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_SYSCONFDIR=/etc$OPREFIX
    -DCMAKE_INSTALL_INCLUDEDIR=$OPREFIX/include
    -DCMAKE_INSTALL_LOCALSTATEDIR=/var$PREFIX
    -DWITH_PLUGINS=NO
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="
        -DCMAKE_INSTALL_LIBDIR=$OPREFIX/${LIBDIRS[$arch]}
    "

    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]} -lsocket"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake
build
xform files/mosquitto.xml > $TMPDIR/$PROG.xml
install_smf network $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
