DESCRIPTION = "IPMI over LAN (RMCP/IPMIv1.5) Server"

HOMEPAGE = "https://github.com/foxconn-bmc-ks/fru-util"
LICENSE = "Microsoft"

DEPENDS += "zlog"
inherit obmc-phosphor-license
INSANE_SKIP_fru-util += "dev-deps"

BB_NO_NETWORK = "0"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
#RDEPENDS_${PN} = "bash python"


FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/foxconn-bmc-ks/fru-util"
SRCREV = "6a8e37c032db3f42879b62b511b5c55837ec5c20"
S = "${WORKDIR}/git"

do_compile() {
        oe_runmake
}

do_install() {
        install -Dm755 ${B}/fru-util/bin/ocs-fru ${D}/${sbindir}/ocs-fru
        install -Dm755 ${B}/frui2clib/lib/libocsfrui2c.so ${D}/${libdir}/libocsfrui2c.so
        install -Dm755 ${B}/Ocslog/lib/libocslog.so ${D}/${libdir}/libocslog.so
        install -Dm755 ${B}/SemLock/lib/libocslock.so ${D}/${libdir}/libocslock.so
}
