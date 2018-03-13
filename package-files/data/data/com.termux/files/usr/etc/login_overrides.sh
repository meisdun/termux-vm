##############################################################################
##
##  This file contains overrides of parameters and functions
##  for login script (${PREFIX}/bin/login).
##
##############################################################################

## How many CPUs VM will have.
QEMU_NPROC="2"

## How much RAM VM will have.
QEMU_RAM="1024"

## To which port SSH will be forwarded from the VM.
QEMU_SSH_PORT="8222"

## Path to the basic image of the OS. This image will be unchanged.
ARCHLINUX_BASE_IMAGE="${PREFIX}/share/qemu/os-images/archlinux-base.qcow2"

## Path to the snapshot image of the OS. All changes will be written to this image.
ARCHLINUX_SNAP_IMAGE="${PREFIX}/var/lib/qemu/archlinux.snap.qcow2"

## Path to the QEMU pid file.
QEMU_PIDFILE="${PREFIX}/var/run/qemu.pid"

##
##  Create a snapshot of HDD where all changes will be written.
##
mksnapimage()
{
    if qemu-img create -q -f qcow2 -b "${ARCHLINUX_BASE_IMAGE}" "${ARCHLINUX_SNAP_IMAGE}" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

##
##  Start QEMU VM.
##
start_qemu_session()
{
    echo -ne '\e]0;QEMU\a'
    exec qemu-system-x86_64 -smp "${QEMU_NPROC}" \
                            -m "${QEMU_RAM}" \
                            -vga none \
                            -nographic \
                            -pidfile "${QEMU_PIDFILE}" \
                            -drive file="${ARCHLINUX_SNAP_IMAGE}",if=virtio \
                            -device virtio-net-pci,netdev=qemunet0 \
                            -netdev "user,id=qemunet0,hostfwd=tcp::${QEMU_SSH_PORT}-:22" \
                            -parallel none \
                            -device virtio-serial \
                            -chardev tty,id=console0,mux=off,path="$(tty)" \
                            -device virtconsole,chardev=console0 \
                            -monitor "unix:${PREFIX}/tmp/qemu-mon,server,nowait"
}

##
##  Connect to the QEMU via SSH.
##
connect_to_qemu()
{
    echo "[*] Waiting for SSH port..."
    while true; do
        if [[ $(echo "porttest" | nc 127.0.0.1 "${QEMU_SSH_PORT}" 2>/dev/null | grep SSH | head -c3) = "SSH" ]]; then
            echo "[*] Connecting to 127.0.0.1:${QEMU_SSH_PORT}..."
            exec ssh -o UserKnownHostsFile=/dev/null \
                     -o StrictHostKeyChecking=no \
                     -p "${QEMU_SSH_PORT}" \
                     -q \
                     admin@localhost
        else
            sleep 1
        fi
    done
}
