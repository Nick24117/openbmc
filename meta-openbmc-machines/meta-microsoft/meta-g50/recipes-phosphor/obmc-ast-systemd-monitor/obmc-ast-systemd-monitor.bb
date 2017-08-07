#**************************************************************
#*                                                            *
#*   Copyright (C) Microsoft Corporation. All rights reserved.*
#*                                                            *
#**************************************************************

SUMMARY = "OpenBMC Systemd Mointor"
DESCRIPTION = "OpenBMC Systemd Mointor Daemon"

inherit obmc-phosphor-license
inherit obmc-phosphor-systemd

SRC_URI += "file://obmc-ast-systemd-monitor.service"
SRC_URI += "file://obmc-ast-systemd-monitor.py"

S = "${WORKDIR}"

do_install() {
	install -d ${D}${sbindir}
	install -m 0755 obmc-ast-systemd-monitor.py  ${D}${sbindir}
}

SYSTEMD_SERVICE_${PN} += "obmc-ast-systemd-monitor.service"
