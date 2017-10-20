DESCRIPTION = "An unladen web framework for building APIs and app backends."
HOMEPAGE = "http://projects.unbit.it/uwsgi/"
SECTION = "net"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=33ab1ce13e2312dddfad07f97f66321f"

SRCNAME = "uwsgi"
SRC_URI = "git://github.com/unbit/uwsgi.git;protocol=https;branch=uwsgi-2.0 \
    file://001-fix_rpath.patch \
    file://002-add_g50.patch \
"

SRCREV="d461b0c7087f181a28d25e8b06320ab5ec637f78"
PV="2.0.15+git${SRCPV}"
S = "${WORKDIR}/git"

inherit setuptools pkgconfig

# prevent host contamination and remove local search paths
export UWSGI_REMOVE_INCLUDES = "/usr/include,/usr/local/include"

export UWSGI_INCLUDES = "${STAGING_INCDIR_NATIVE}"

export UWSGI_PROFILE = "g50"

DEPENDS += " \
    openssl \
"

RDEPENDS_${PN} += " \
    openssl \
    util-linux \
"

CLEANBROKEN = "1"
