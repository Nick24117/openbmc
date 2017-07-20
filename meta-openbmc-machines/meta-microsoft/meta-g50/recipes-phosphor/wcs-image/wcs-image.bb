# Copyright (C) 2017 jasonluo <jason.cc.luo@mail.foxconn.com>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Phosphor OpenBMC Image Monitoring Service"
DESCRIPTION = "Phosphor OpenBMC Image Monitoring Daemon."
PR = "r1"

inherit obmc-phosphor-license
inherit obmc-phosphor-systemd

DEPENDS += "systemd"
RDEPENDS_${PN} += "libsystemd"

SRC_URI += "file://check_image.sh"
SRC_URI += "file://obmc-image-monitor.service"
SRC_URI += "file://check_image_hash.sh"
SRC_URI += "file://public.pub"

do_install_append() {
        install -d ${D}${sbindir}
        install -d ${D}/etc
        install -d ${D}${systemd_unitdir}/system/
        install -m 0755 ${WORKDIR}/check_image_hash.sh ${D}${sbindir}
        install -m 0755 ${WORKDIR}/public.pub ${D}/etc/
        install -m 0755 ${WORKDIR}/check_image.sh ${D}${sbindir}

}

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
FILES_${PN} += " check_image.sh "

SYSTEMD_SERVICE_${PN} += "obmc-image-monitor.service"

