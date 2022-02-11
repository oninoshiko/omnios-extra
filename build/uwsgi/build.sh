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
# Copyright 2022 A Hettinger (oninoshiko@gmail.com)

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

build() {
  python uwsgiconfig.py --build core
  python uwsgiconfig.py --plugin plugins/python core
  python uwsgiconfig.py --plugin plugins/psgi core
  python uwsgiconfig.py --plugin plugins/php core
  python uwsgiconfig.py --plugin plugins/http core
  python uwsgiconfig.py --plugin plugins/cgi core
  python uwsgiconfig.py --plugin plugins/syslog core
  python uwsgiconfig.py --plugin plugins/rsyslog core
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
