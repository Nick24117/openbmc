#!/bin/sh

echo "Check the Firmware File before BMC reboot"
result=$(sh check_image_hash.sh)
if [[ ("$result" == *"Hashkey valid"*) || ("$result" == *"Unsigned Firmware is available."*)  ]]; then

    bmc_fw=/var/wcs/home/image-bmc
    bmc1_fw=/var/wcs/home/image-bmc2
    if test -e $bmc_fw && test -f $bmc_fw
    then
        echo "Found Primary G50-BMC FW-Image:" $bmc_fw
        mv -f $bmc_fw /run/initramfs/
        exit 0
    fi

    if test -e $bmc1_fw && test -f $bmc1_fw
    then
        echo "Found Secondary G50-BMC FW-Image:" $bmc1_fw
        mv -f $bmc1_fw /run/initramfs/
        exit 0
    fi
else
    echo "BMC Firmware is not available."
    exit 1
fi
