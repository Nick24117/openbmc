def to_upper(string):
    return string.upper()

PRETTY_NAME = "${@to_upper(MACHINE)} ${BUILD_ID}! (Base: ${DISTRO_NAME} ${VERSION})"
