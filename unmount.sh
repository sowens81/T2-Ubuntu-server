CHROOT="/home/sowens/T2-Ubuntu-server/work/chroot_noble"

sudo umount -lf $CHROOT/proc  2>/dev/null || true
sudo umount -lf $CHROOT/sys   2>/dev/null || true
sudo umount -lf $CHROOT/sys   2>/dev/null || true
sudo umount -lf $CHROOT/dev   2>/dev/null || true
sudo umount -lf $CHROOT/run   2>/dev/null || true

mount | grep "$CHROOT"

sudo rm -rf "/home/sowens/T2-Ubuntu-server/work/"