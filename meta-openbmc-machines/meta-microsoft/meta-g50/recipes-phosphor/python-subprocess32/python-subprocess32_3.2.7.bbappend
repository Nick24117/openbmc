do_install() {
    distutils_do_install
    rm -rf ${D}/${PYTHON_SITEPACKAGES_DIR}/subprocess.py
    rm -rf ${D}/${PYTHON_SITEPACKAGES_DIR}/subprocess.pyc
    ln -s subprocess32.py ${D}${PYTHON_SITEPACKAGES_DIR}/subprocess.py
    ln -s subprocess32.pyc ${D}${PYTHON_SITEPACKAGES_DIR}/subprocess.pyc
}
