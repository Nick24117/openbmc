SUMMARY = "Phosphor python library"
DESCRIPTION = "Phosphor python library."
HOMEPAGE = "http://github.com/openbmc/pyphosphor"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

inherit allarch
inherit setuptools

SRC_URI += "git://csibmc@csibmc.visualstudio.com:22/G50/_git/pyphosphor;protocol=ssh;"

SRCREV = "c60ba254bfb11321a1b99a7dd857e237e33bc132"

S = "${WORKDIR}/git"
