#!/bin/sh
# /*************************************************************
# *                                                            *
# *   Copyright (C) Microsoft Corporation. All rights reserved.*
# *                                                            *
# *************************************************************/

WCSHOME='/var/wcs/home'
SIGNEDFIRMWARE='signed_binary.bin'
BMCFIRMWARE='image-bmc'
BMCFIRMWARE2='image-bmc2'
SIGNED_SIZE=$(((32*1024*1024)+256))
UNSIGNED_SIZE=$(((32*1024*1024)))
FW_SIGNED_SUPPORT="FALSE"
FW_TEMP=""

if [ ! -f $WCSHOME/$BMCFIRMWARE ] && [ ! -f $WCSHOME/$BMCFIRMWARE2 ]; then
	echo 'Firmware is not available.'
	exit 1
fi

if [ -f $WCSHOME/$BMCFIRMWARE ]; then
	FW_TEMP=$BMCFIRMWARE
	echo 'Firmware is available:'$FW_TEMP
else
	FW_TEMP=$BMCFIRMWARE2
	echo 'Firmware is available:'$FW_TEMP
fi

firmware_size="$(ls $WCSHOME/ -al | grep $FW_TEMP | awk '{print $5}')"

if [ "$FW_SIGNED_SUPPORT" = "TRUE" ]; then

	# firmware_size="$(ls $WCSHOME/ -al | grep $BMCFIRMWARE | awk '{print $5}')"

	if [ $firmware_size -eq $SIGNED_SIZE ]; then
		echo 'Signed Firmware'
	elif [ $firmware_size -eq $UNSIGNED_SIZE ]; then
		echo 'UnSigned Firmware'
		rm -rf $WCSHOME/$FW_TEMP >& /dev/null
		exit 1
	else
		rm -rf $WCSHOME/$FW_TEMP >& /dev/null
		echo 'Unknown Firmware Size'
		exit 1
	fi
	# BMC has two types of image, image-bmc and image-bmc2, 
	# but only one image can be update at same time.
	# BMC will rename the image-bmc/image-bmc2 to signed_binary.bin first.
	# Then extracts the data from singed_binary.bin.
	mv $WCSHOME/$FW_TEMP $WCSHOME/$SIGNEDFIRMWARE
	# Divide signed firmware image into original fw(image-bmc) and encrypted-hashkey(signed-sha256.bin).
	dd if=$WCSHOME/$SIGNEDFIRMWARE of=$WCSHOME/$FW_TEMP count=65536 >& /dev/null
	dd if=$WCSHOME/$SIGNEDFIRMWARE of=$WCSHOME/signed-sha256.bin bs=1 skip=33554432 count=256 >& /dev/null
	# Using public key to extract data from  encrypted-hashkey file.
	openssl rsautl -verify -pubin -inkey /etc/public.pub < $WCSHOME/signed-sha256.bin > $WCSHOME/plain_hash.bin

	# Get the hash key value from data.
	hashcmd1="$(openssl asn1parse -inform der -in $WCSHOME/plain_hash.bin | awk '/DUMP/ {print tolower(substr($9,7,length($9))) }')"
	# Get the sha256sum value of original fw image.
	hashcmd2="$(sha256sum $WCSHOME/$FW_TEMP | awk '{print $1}')"

	hashvalue1=${hashcmd1}
	hashvalue2=${hashcmd2}

	rm -rf $WCSHOME/$SIGNEDFIRMWARE >& /dev/null
	rm -rf $WCSHOME/signed-sha256.bin >& /dev/null
	rm -rf $WCSHOME/plain_hash.bin >& /dev/null

	if [ "$hashvalue1" = "$hashvalue2" ]; then
		echo "Hashkey valid"
	else
		rm -rf $WCSHOME/$FW_TEMP >& /dev/null
		echo "Hashkey invalid"
	fi
else
	if [ -f $WCSHOME/$FW_TEMP ]; then
			if [ $firmware_size -eq $SIGNED_SIZE ]; then
				rm -rf $WCSHOME/$FW_TEMP >& /dev/null
				echo 'Signed Firmware is not support.'
				exit 1
			elif [ $firmware_size -eq $UNSIGNED_SIZE ]; then
				echo 'Unsigned Firmware is available.'
				exit 0
			else
				rm -rf $WCSHOME/$FW_TEMP >& /dev/null
				echo 'Unknown Firmware Size'
				exit 1
			fi
	fi
fi	

exit 0
