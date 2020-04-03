#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*};

symlink_from_file() {
   cat $1 | while read line
   do
      target=$(echo $line | sed 's/;/ /g' | awk '{printf $2}');
      symlink=$(echo $line | sed 's/;/ /g' | awk '{printf $1}');
      ln -sf $target $2/$symlink;
      chown 0:0 $2/$symlink;
      chmod 755 $2/$symlink;
   done
   chown -R 0:0 $2;
   chmod -R 755 $2;
}

mount -o rw,remount /system;
mount -o rw,remount /system/usr;

cd /system/bin;
cp $MODDIR/symlinks/symlinks_bin .;
symlink_from_file "$(pwd)/symlinks_bin" "$(pwd)";

cd /system/usr/libexec/git-core;
cp $MODDIR/symlinks/symlinks_git_core .;
symlink_from_file "$(pwd)/symlinks_git_core" "$(pwd)";

mount -o ro,remount /system;
mount -o ro,remount /system/usr;
