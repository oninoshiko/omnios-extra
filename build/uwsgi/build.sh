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
# Copyright 2022 A Hettinger (ahettinger@prominic.net)

. ../../lib/build.sh

PROG=uwsgi
VER=2.0.20
PKG=ooce/server/uwsgi
SUMMARY="fast, self-healing application container server"
DESC="uwsgi - $SUMMARY"

[ $RELVER -lt 151030 ] && exit 0

#https://projects.unbit.it/downloads/uwsgi-2.0.20.tar.gz
ARCHIVE_TYPES="tar.gz"
set_mirror "https://projects.unbit.it"
set_checksum sha256 "88ab9867d8973d8ae84719cf233b7dafc54326fcaec89683c3f9f77c002cdff9"

set_arch 64


OPREFIX=$PREFIX
PREFIX+=/$PROG
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$PREFIX
VARPATH=/var$PREFIX
RUNPATH=$VARPATH/run

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

build() {
  pushd $TMPDIR/$BUILDDIR >/dev/null
  python uwsgiconfig.py --build core || logerr "Build failed: core"
  python uwsgiconfig.py --plugin plugins/python core || logerr "Build plugin failed: python"
  python uwsgiconfig.py --plugin plugins/psgi core || logerr "Build plugin failed: psgi"
  python uwsgiconfig.py --plugin plugins/http core || logerr "Build plugin failed: http"
  python uwsgiconfig.py --plugin plugins/cgi core || logerr "Build plugin failed: cgi"
  python uwsgiconfig.py --plugin plugins/syslog core || logerr "Build plugin failed: syslog"
  python uwsgiconfig.py --plugin plugins/rsyslog core || logerr "Build plugin failed: rsyslog"
  popd >/dev/null
}

init
download_source "downloads" $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
