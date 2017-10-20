inherit extrausers

EXTRA_USERS_PARAMS = " \
  useradd -ou 0 -d /home/root -G sudo,root -p '\$1\$PzAVtlJm\$wJu6wrLB52nIr2uZHxMhJ/' sysadmin; \
  useradd -ou 0 -d /home/root -G sudo,root -p '\$1\$Yy4z1f7q\$cwYsZD6ibhG7zYR7HQt0a1' admin; \
  usermod -L root; \
  "
OBMC_IMAGE_EXTRA_INSTALL_append = " oob-ipmid"
OBMC_IMAGE_EXTRA_INSTALL_append = " wcs-image"
