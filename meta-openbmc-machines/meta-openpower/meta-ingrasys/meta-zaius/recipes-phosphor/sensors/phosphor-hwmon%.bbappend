FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

ZAIUS_CHIPS = "i2c@1e78a000/i2c-bus@40/ucd90160@64 \
                i2c@1e78a000/i2c-bus@40/lm75@4a \
                i2c@1e78a000/i2c-bus@380/lm75@4a \
                i2c@1e78a000/i2c-bus@380/lm75@4f \
                i2c@1e78a000/i2c-bus@380/nct7904@2d \
                i2c@1e78a000/i2c-bus@380/nct7904@2e \
                i2c@1e78a000/i2c-bus@380/hdd@71 \
                i2c@1e78a000/i2c-bus@380/hdd@72 \
                i2c@1e78a000/i2c-bus@380/hdd@73 \
                i2c@1e78a000/i2c-bus@380/hdd@74 \
                i2c@1e78a000/i2c-bus@380/hdd@75 \
                i2c@1e78a000/i2c-bus@380/hdd_expander@5f \
                i2c@1e78a000/i2c-bus@140/i2c-switch@71/i2c@0/gpu1@4c \
                i2c@1e78a000/i2c-bus@80/i2c-switch@71/i2c@1/gpu1@4c \
                "
ZAIUS_ITEMSFMT = "ahb/apb/{0}.conf"

ZAIUS_ITEMS = "${@compose_list(d, 'ZAIUS_ITEMSFMT', 'ZAIUS_CHIPS')}"

ZAIUS_OCCS = " \
              00--00--00--06/sbefifo1-dev0/occ-hwmon.1 \
              00--00--00--0a/fsi1/slave@01--00/01--01--00--06/sbefifo2-dev0/occ-hwmon.2 \
              "
ZAIUS_OCCSFMT = "devices/platform/gpio-fsi/fsi0/slave@00--00/{0}.conf"
ZAIUS_OCCITEMS = "${@compose_list(d, 'ZAIUS_OCCSFMT', 'ZAIUS_OCCS')}"

ITEMS = "iio-hwmon.conf"

ENVS = "obmc/hwmon/{0}"
SYSTEMD_ENVIRONMENT_FILE_${PN} += "${@compose_list(d, 'ENVS', 'ZAIUS_ITEMS')}"
SYSTEMD_ENVIRONMENT_FILE_${PN} += "${@compose_list(d, 'ENVS', 'ZAIUS_OCCITEMS')}"
SYSTEMD_ENVIRONMENT_FILE_${PN} += " ${@compose_list(d, 'ENVS', 'ITEMS')}"
