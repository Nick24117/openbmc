inherit extrausers

EXTRA_USERS_PARAMS = " \
  useradd -ou 0 -d /home/root -G sudo,root -p '\$1\$PzAVtlJm\$wJu6wrLB52nIr2uZHxMhJ/' sysadmin; \
  usermod -L root; \
  "
OBMC_IMAGE_EXTRA_INSTALL_append = " oob-ipmid"
