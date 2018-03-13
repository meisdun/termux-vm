#!/data/data/com.termux/files/usr/bin/sh
##
##  Fix permissions of files
##

SCRIPT_PATH=$(realpath "${0}")
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
BASE_DIR="${SCRIPT_DIR}/../"

echo -n "[*] Fixing permissions... "
(
    chmod 644 "${BASE_DIR}/package-files/DEBIAN/control"
    chmod 644 "${BASE_DIR}/package-files/DEBIAN/conffiles"
    chmod 755 "${BASE_DIR}/package-files/DEBIAN/preinst"
    chmod 755 "${BASE_DIR}/package-files/DEBIAN/prerm"
    chmod 755 "${BASE_DIR}/package-files/DEBIAN/postinst"
    chmod 755 "${BASE_DIR}/package-files/DEBIAN"

    find "${BASE_DIR}/package-files/data" -type d -print0 | xargs -0 chmod 700
    find "${BASE_DIR}/package-files/data" -type f -executable -print0 | xargs -0 chmod 700
    find "${BASE_DIR}/package-files/data" -type f ! -executable -print0 | xargs -0 chmod 600
    find "${BASE_DIR}/package-files/data/data/com.termux/files/usr/lib" "${BASE_DIR}/package-files/data/data/com.termux/files/usr/libexec" -type f | grep -P '.+\.so(\.[0-9\.]+)?$' | xargs chmod 600
exit 0) >/dev/null 2>&1
# errors are not critical here, so always printing 'ok'
echo "ok"
