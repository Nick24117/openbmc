DESCRIPTION = "Linux kernel for OpenBMC"
SECTION = "kernel"
LICENSE = "GPLv2"

KCONFIG_MODE="--alldefconfig"

KSRC ?= "git://github.com/foxconn-bmc-ks/linux;protocol=git;branch=${KBRANCH}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "${KSRC}"
SRC_URI += "file://phosphor-gpio-keys.scc"
SRC_URI += "file://phosphor-gpio-keys.cfg"
SRC_URI += "file://phosphor-vlan.scc"
SRC_URI += "file://phosphor-vlan.cfg"
SRC_URI += "${@mf_enabled(d, 'obmc-ubi-fs', 'file://0001-ARM-dts-Aspeed-Witherspoon-Update-BMC-partitioning.patch')}"
SRC_URI += "file://linux-dev-4.10-01-16-fsi-sbefifo-Rename-sbefifo_release_client-for-consistency.patch"
SRC_URI += "file://linux-dev-4.10-02-16-fsi-sbefifo-Add-tracing-of-transfers.patch"
SRC_URI += "file://linux-dev-4.10-03-16-fsi-gpio-Trace-busy-count.patch"
SRC_URI += "file://linux-dev-4.10-04-16-fsi-occ-Add-tracepoints.patch"
SRC_URI += "file://linux-dev-4.10-05-16-fsi-sbefifo-don-t-delete-canceled-xfrs-in-write.patch"
SRC_URI += "file://linux-dev-4.10-06-16-hwmon-p9_sbe-Rename-context-variable.patch"
SRC_URI += "file://linux-dev-4.10-07-16-hwmon-p9_sbe-Rename-lock-member-of-struct-p9_sbe_occ.patch"
SRC_URI += "file://linux-dev-4.10-08-16-hwmon-p9_sbe-Convert-client_lock-from-a-spinlock-to-a-mutex.patch"
SRC_URI += "file://linux-dev-4.10-09-16-fsi-sbefifo-Avoid-using-a-timer-to-drive-FIFO-transfers.patch"
SRC_URI += "file://linux-dev-4.10-10-16-fsi-sbefifo-Switch-to-mutex-in-work-function.patch"
SRC_URI += "file://linux-dev-4.10-11-16-fsi-sbefifo-Switch-list_lock-from-spinlock-to-mutex.patch"
SRC_URI += "file://linux-dev-4.10-12-16-drivers-fsi-occ-switch-to-irqsave-and-irqrestore.patch"


LINUX_VERSION_EXTENSION ?= "-${SRCREV}"

PV = "${LINUX_VERSION}+git${SRCPV}"

COMPATIBLE_MACHINE_${MACHINE} = "openbmc"

do_patch_append() {
        for DTB in "${KERNEL_DEVICETREE}"; do
               DT=`basename ${DTB} .dtb`
                if [ -r "${WORKDIR}/${DT}.dts" ]; then
                        cp ${WORKDIR}/${DT}.dts \
                                ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts
               fi
       done
}

inherit kernel
require recipes-kernel/linux/linux-yocto.inc

KERNEL_FEATURES_append = " phosphor-vlan"
KERNEL_FEATURES_remove_qemuall = " phosphor-vlan"
