#!/data/data/com.termux/files/usr/bin/sh

##############################################################################
##
##  Values for control file
##

PACKAGE_NAME="termux-vm"
PACKAGE_ARCHITECTURE="aarch64"
PACKAGE_VERSION="2.1"
PACKAGE_MAINTAINER="Leonid Plyushch <leonid.plyushch@gmail.com> @xeffyr"
PACKAGE_DESCRIPTION="Termux environment that powered by QEMU"

##
##############################################################################

SCRIPT_PATH=$(realpath "${0}")
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
BASE_DIR="${SCRIPT_DIR}/../"

DEBFILE_PATH="${BASE_DIR}/${PACKAGE_NAME}_${PACKAGE_VERSION}_${PACKAGE_ARCHITECTURE}.deb"
INSTALLER_PATH="${BASE_DIR}/${PACKAGE_NAME}-${PACKAGE_VERSION}-${PACKAGE_ARCHITECTURE}_installer.deb.sh"

if [ -e "${INSTALLER_PATH}" ] || [ -e "${DEBFILE_PATH}" ]; then
    echo -n "[*] Deleting previous package... "
    if rm -f "${DEBFILE_PATH}" "${INSTALLER_PATH}" > /dev/null 2>&1; then
        echo "ok"
    else
        echo "fail"
        exit 1
    fi
fi

## generate image file for ArchLinux
if ! sh "${SCRIPT_DIR}/build-archlinux-image.sh"; then
    exit 1
fi

PACKAGE_SIZE=$(du -s "${BASE_DIR}/package-files" | awk '{ print $1 }')
[ -z "${PACKAGE_SIZE}" ] && PACKAGE_SIZE="500000"

## generate control file
cat <<- EOF > "${BASE_DIR}/package-files/DEBIAN/control"
Package: ${PACKAGE_NAME}
Essential: yes
Architecture: ${PACKAGE_ARCHITECTURE}
Installed-Size: ${PACKAGE_SIZE}
Maintainer: ${PACKAGE_MAINTAINER}
Version: ${PACKAGE_VERSION}
Description: ${PACKAGE_DESCRIPTION}
EOF

## fix permissions
sh "${SCRIPT_DIR}/fix-permissions.sh"

if [ ! -z "${QUICK_DEB}" ]; then
    DPKG_COMP_PARAMS="-Zgzip"
else
    DPKG_COMP_PARAMS="-Zxz -z9"
fi

echo -n "[*] Building package... "
if dpkg-deb --uniform-compression ${DPKG_COMP_PARAMS} -b "${BASE_DIR}/package-files" "${DEBFILE_PATH}" > /dev/null 2>&1; then
    echo "ok"
else
    echo "fail"
    exit 1
fi

echo -n "[*] Generating SHA-256... "
DEBFILE_SHA256=$(sha256sum "${DEBFILE_PATH}" | awk '{ print $1 }')
if [ ! -z "${DEBFILE_SHA256}" ]; then
    echo "ok"
else
    echo "fail"
    exit 1
fi

echo -n "[*] Building installer... "
(set -e
    sed "s%\@__DEBFILE_SHA256__\@%${DEBFILE_SHA256}%g" "${SCRIPT_DIR}/installer_header.sh" > "${INSTALLER_PATH}"
    cat "${DEBFILE_PATH}" >> "${INSTALLER_PATH}"
    rm -f "${DEBFILE_PATH}"
exit 0) > /dev/null 2>&1
if [ "${?}" = "0" ]; then
    echo "ok"
else
    echo "fail"
    exit 1
fi

echo "[*] Done."
