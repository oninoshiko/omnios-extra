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
BUILD_DEPENDS_IPS+="
  runtime/python-27
  runtime/python-39
"

OPREFIX=$PREFIX
PREFIX+=/$PROG
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$PREFIX
VARPATH=/var$PREFIX
RUNPATH=$VARPATH/run

SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

build() {
  pushd $TMPDIR/$BUILDDIR >/dev/null
  logmsg "Building uwsgi"
  python uwsgiconfig.py --build nolang || logerr "Build core failed"
  PYTHON=python2.7 ./uwsgi --build-plugin "plugins/python python27" nolang || logerr "Build plugin failed: python27"
  PYTHON=python3.9 ./uwsgi --build-plugin "plugins/python python39" nolang || logerr "Build plugin failed: python39"
  python uwsgiconfig.py --plugin plugins/psgi nolang || logerr "Build plugin failed: psgi"
  python uwsgiconfig.py --plugin plugins/http nolang || logerr "Build plugin failed: http"
  python uwsgiconfig.py --plugin plugins/cgi nolang || logerr "Build plugin failed: cgi"
  python uwsgiconfig.py --plugin plugins/syslog nolang || logerr "Build plugin failed: syslog"
  python uwsgiconfig.py --plugin plugins/rsyslog nolang || logerr "Build plugin failed: rsyslog"

  logmsg "Installing uwsgi"
  logcmd mkdir -p $DESTDIR/$PREFIX/bin
  logcmd mkdir -p $DESTDIR/$PREFIX/lib
  logcmd cp -r $TMPDIR/$BUILDDIR/uwsgi $DESTDIR/$PREFIX/bin || logerr "Install of core failed"
  logcmd cp -r $TMPDIR/$BUILDDIR/*_plugin.so $DESTDIR/$PREFIX/lib || logerr "Install of plugins failed"
  popd >/dev/null
}

init
download_source "downloads" $PROG $VER
patch_source
prep_build
build

for file in $DESTDIR/$PREFIX/lib/*.so; do
  basename=$(basename $file .so)
  logmsg "building $PROG-$basename from $file"
  manifest_start $TMPDIR/manifest.$PROG-$basename
  manifest_add $PREFIX/lib $basename.so
  manifest_finalise $TMPDIR/manifest.$PROG-$basename $OPREFIX
  PKG=$PKG-$basename RUN_DEPENDS_IPS="ooce/server/uwsgi" make_package -seed $TMPDIR/manifest.$PROG-$basename
done
install_smf ooce server-uwsgi.xml
manifest_uniq $TMPDIR/manifest.$PROG-core $TMPDIR/manifest.uwsgi-*
manifest_finalise $TMPDIR/manifest.$PROG-core $OPREFIX etc
make_package -seed $TMPDIR/manifest.$PROG-core core.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
