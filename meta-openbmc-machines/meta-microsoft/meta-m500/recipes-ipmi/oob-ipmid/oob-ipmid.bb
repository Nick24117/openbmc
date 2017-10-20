DESCRIPTION = "IPMI over LAN (RMCP/IPMIv1.5) Server"

HOMEPAGE = "https://csibmc.visualstudio.com/G50/_git/oob-ipmid"
LICENSE = "Microsoft"

inherit obmc-phosphor-license
inherit obmc-phosphor-systemd

BB_NO_NETWORK = "0"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://csibmc@csibmc.visualstudio.com:22/G50/_git/oob-ipmid;protocol=ssh;"
SRCREV = "1aee1b42ebefd92607811bb61716a8378629168a"

S = "${WORKDIR}/git"

SYSTEMD_SERVICE_${PN} += "${PN}.service"

do_configure[noexec] = "1"

do_compile() {
        oe_runmake DESTDIR=${D} LIBDIR=${libdir} INCDIR=${includedir}
}

do_install() {
        oe_runmake install DESTDIR=${D} BINDIR=${bindir}
}

