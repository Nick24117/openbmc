SUMMARY = "OpenBMC WOL control"
DESCRIPTION = "OpenBMC WOL control"
PR = "r1"

inherit skeleton-gdbus
inherit obmc-phosphor-dbus-service
inherit pkgconfig

RDEPENDS_${PN} += "libsystemd"
SKELETON_DIR = "op-wolctl"

DBUS_SERVICE_${PN} += "org.openbmc.control.WOL.service"
