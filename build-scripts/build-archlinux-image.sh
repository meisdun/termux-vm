#!/data/data/com.termux/files/usr/bin/sh
##
##  Combine all parts of ArchLinux's image into single QCOW2 image
##

SCRIPT_PATH=$(realpath "${0}")
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
BASE_DIR="${SCRIPT_DIR}/../"
OSIMAGE_DIR="${BASE_DIR}/os-image"
OUTPUT_IMAGE_PATH="${BASE_DIR}/package-files/data/data/com.termux/files/usr/share/qemu/os-images/archlinux-base.qcow2"

echo -n "[*] Building ArchLinux image... "
cat "${OSIMAGE_DIR}/archlinux.qcow2.00" \
    "${OSIMAGE_DIR}/archlinux.qcow2.01" \
    "${OSIMAGE_DIR}/archlinux.qcow2.02" \
    "${OSIMAGE_DIR}/archlinux.qcow2.03" \
    "${OSIMAGE_DIR}/archlinux.qcow2.04" \
    "${OSIMAGE_DIR}/archlinux.qcow2.05" \
    "${OSIMAGE_DIR}/archlinux.qcow2.06" \
    "${OSIMAGE_DIR}/archlinux.qcow2.07" \
    "${OSIMAGE_DIR}/archlinux.qcow2.08" \
    > "${OUTPUT_IMAGE_PATH}" 2>/dev/null

if [ "${?}" = "0" ]; then
    echo "ok"
else
    echo "fail"
    exit 1
fi

echo -n "[*] Checking SHA-256 of generated ArchLinux image... "
if [ $(sha256sum "${OUTPUT_IMAGE_PATH}" 2>/dev/null | awk '{ print $1 }' 2>/dev/null) = $(cat "${OSIMAGE_DIR}/CHECKSUM.sha256" 2>/dev/null) ]; then
    echo "ok"
else
    echo "fail"
    exit 1
fi
