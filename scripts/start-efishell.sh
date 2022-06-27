#!/bin/sh
ovmf_code=${OVMF_CODE:-/usr/share/OVMF/OVMF_CODE.secboot.fd}
ovmf_vars=${OVMF_VARS:-./OVMF_VARS.fd}
DISK=$1
qemu-system-x86_64 -enable-kvm -M q35 -nographic \
                   -cpu host,hv_relaxed,hv_vapic,hv-spinlocks=0xfff -smp 2 -m 2G -no-hpet \
                   -global ICH9-LPC.disable_s3=1 \
                   -global isa-fdc.driveA= \
                   -boot menu=on \
                   -drive if=pflash,format=raw,unit=0,readonly=on,file=${ovmf_code} \
                   -drive if=pflash,format=raw,file=${ovmf_vars} \
                   -drive file=fat:rw:$DISK
