SUMMARY = "Phosphor OpenBMC Event Management"
DESCRIPTION = "Phosphor OpenBMC event management reference implementation."
HOMEPAGE = "https://github.com/openbmc/phosphor-event"
PR = "r1"


inherit obmc-phosphor-license
inherit obmc-phosphor-event-mgmt
inherit obmc-phosphor-sdbus-service
inherit obmc-phosphor-c-daemon

TARGET_CPPFLAGS += "-std=c++11 -fpic"

SRC_URI += "git://csibmc@csibmc.visualstudio.com:22/G50/_git/phosphor-event;protocol=ssh;"

SRCREV = "0b4faf6b98f8a6b66c51a2e9c6853a67c8b521f0"

RDEPENDS_${PN} += "libsystemd"
DEPENDS += "systemd"


S = "${WORKDIR}/git"
INSTALL_NAME = "event_messaged"

do_install() {
        install -d ${D}/var/lib/obmc/events/
        install -m 0755 -d ${D}${sbindir}
        install -m 0755 ${S}/${INSTALL_NAME} ${D}/${sbindir}/obmc-phosphor-eventd
}
