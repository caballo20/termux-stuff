#!/data/data/com.termux/files/usr/bin/sh
set -e

unset LD_PRELOAD

TERMUX_BUILDER_ROOTFS_DIR="${HOME}/.termux-builder"
export PROOT_L2S_DIR="${TERMUX_BUILDER_ROOTFS_DIR}/.l2s"

if [ ! -e "${TERMUX_BUILDER_ROOTFS_DIR}/.installed" ]; then
    echo "[!] Termux Builder is not installed or installation was not finished successfully."
    echo "    Please, reinstall it."
    exit 1
fi

if [ ! -e "${TERMUX_BUILDER_ROOTFS_DIR}/.l2s" ]; then
    if ! mkdir -p "${PROOT_L2S_DIR}"; then
        echo "[!] Failed to create link2symlink directory '${TERMUX_BUILDER_ROOTFS_DIR}/.l2s'."
        exit 1
    fi
fi

if ! echo "nameserver 8.8.8.8" > "${TERMUX_BUILDER_ROOTFS_DIR}/etc/resolv.conf"; then
    echo "[!] Failed to update /etc/resolv.conf."
    exit 1
fi

cd / > /dev/null 2>&1 || true
exec proot \
        -0 \
        -b "${HOME}:/home/termux" \
        -b "/dev:/dev" \
        -b "/proc:/proc" \
        -b "/sys:/sys" \
        -b "/system:/system" \
        -r "${TERMUX_BUILDER_ROOTFS_DIR}" \
        -q qemu-x86_64 \
        --link2symlink \
        /bin/su - builder
