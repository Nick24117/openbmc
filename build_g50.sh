#!/bin/bash -x

REPO_DIR=`pwd`

echo "
Checking if build directory ../build_dir exists..."
if [ ! -d ../build_dir ]; then
    echo "No build directory. Creating ../build_dir"
    mkdir ../build_dir
else
    echo "Directory ../build_dir already exists"
fi

cd $REPO_DIR/../build_dir

echo "
Set the conf file for build and run config"
TEMPLATECONF=$REPO_DIR/meta-openbmc-machines/meta-microsoft/meta-g50/conf source $REPO_DIR/oe-init-build-env
touch conf/sanity.conf
bitbake obmc-phosphor-image

