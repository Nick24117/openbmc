PACKAGECONFIG += "networkd"
FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"
SRC_URI += "file://default.network"
SRC_URI += "file://shutdown-watchdog.conf"
SRC_URI += "file://0100-systemd_networkd_dbus_setaddress.patch"
SRC_URI += "file://0101-add_watchdog_check_file_before_reboot.patch"

FILES_${PN} += "${libdir}/systemd/network/default.network"
FILES_${PN} += "${libdir}/systemd/system.conf.d/shutdown-watchdog.conf"

do_install_append() {
        install -m 644 ${WORKDIR}/default.network ${D}${libdir}/systemd/network/
        install -m 644 -D ${WORKDIR}/shutdown-watchdog.conf ${D}${libdir}/systemd/system.conf.d/shutdown-watchdog.conf

        #TODO Remove after this issue is resolved
        #https://github.com/openbmc/openbmc/issues/152
        #ln -s /dev/null ${D}/etc/systemd/system/systemd-hwdb-update.service
}
