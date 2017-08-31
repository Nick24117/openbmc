#**************************************************************
#*                                                            *
#*   Copyright (C) Microsoft Corporation. All rights reserved.*
#*                                                            *
#**************************************************************

SUMMARY = "OpenBMC Redfish"
DESCRIPTION = "OpenBMC Redfish"

inherit obmc-phosphor-license
inherit obmc-phosphor-systemd
inherit autotools

BB_NO_NETWORK = "0"

RDEPENDS_${PN} = "bash python"

SRC_URI = "git://csibmc@csibmc.visualstudio.com:22/G50/_git/redfish;protocol=ssh;"
SRCREV="eb892a097f61eb6ec146ccb8680e35756623e9fa"


FILESEXTRAPATHS_append := "${THISDIR}/redfish:"


S = "${WORKDIR}/git"
FILES_${PN} += "${libdir}/*"
FILES_SOLIBSDEV = ""
FILES_${PN} += "${libdir}/*.so"


HASHSTYLE = "gnu"
INCLUDES = "-I${S}/SharedLib/SemLock -I${S}/security -I${S}/Ocslog -I${S}/Utils"

do_compile(){
        ${CC} -I${S} ${INCLUDES} -fPIC -lrt -lcrypt -shared -Wl,--hash-style=${HASHSTYLE} -o libauth.so -Wl,-soname,libauth.so ${S}/security/auth.c ${S}/SharedLib/SemLock/ocslock.c
        ${CC} -I${S} -fPIC -L${B} -lauth -o ocslocks-init ${S}/SharedLib/SemLock/ocslocks-init.c
}

do_install() {
    install -Dm755 ${B}/libauth.so ${D}${libdir}/libauth.so
    install -Dm755 ${B}/ocslocks-init ${D}${sbindir}/ocslocks-init
    install -Dm755 ${S}/run_redfish.sh ${D}${libdir}/ 
    install ${S}/cert.pem ${D}${libdir}/
    install -Dm644 ${S}/SharedLib/SemLock/ocslock.h ${D}${includedir}/ocslock.h
    install -d ${D}${libdir}/redfish
    cp -rf ${S}/source/* ${D}${libdir}/redfish/
}


FILESEXTRAPATHS_append := "${THISDIR}/obmc-redfish:"
SYSTEMD_SERVICE_${PN} += "obmc-${PN}.service"
SYSTEMD_SERVICE_${PN} += "obmc-ocslocks-init.service"
