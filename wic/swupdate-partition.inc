part --source rootfs --uuid "fedcba98-7654-3210-cafe-5e0710000001" --size 1000M   --extra-space 128M --overhead-factor 1 --label systema --align 1024 --fstype=ext4 --mkfs-extraopts "-T default"
part  --source rootfs --uuid "fedcba98-7654-3210-cafe-5e0710000002" --size 1000M   --extra-space 128M --overhead-factor 1 --label systemb --align 1024 --fstype=ext4 --mkfs-extraopts "-T default"
