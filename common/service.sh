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

cp_man() {
   man_dir=$1;
   echo $man_dir;
   if [[ ! -d "/system/usr/share/man/$man_dir" ]]; then
      mkdir -p /system/usr/share/man/$man_dir;
   fi

   for man_file in $MODDIR/system/usr/share/man/$man_dir/*; do
      cp -f $MODDIR/system/usr/share/man/$man_dir/$man_file /system/usr/share/man/$man_dir;
      chown 0:0 /system/usr/share/man/$man_dir/$man_file;
      chmod 644 /system/usr/share/man/$man_dir/$man_file;
   done
}

mount -o rw,remount /system;

cd /system/bin;
cp $MODDIR/custom/symlinks_bin .;
symlink_from_file "$(pwd)/symlinks_bin" "$(pwd)";

cd /system/usr/libexec/git-core;
cp $MODDIR/custom/symlinks_git_core .;
symlink_from_file "$(pwd)/symlinks_git_core" "$(pwd)";

mount -o ro,remount /system;

mount -o rw,remount /system/usr/share;

for dir in $MODDIR/system/usr/share/man/man*/; do
    dir="${dir%/}";
    dir="${dir##*/}";
    cp_man $dir;
done

if [[ -s "/system/bin/mandoc" ]]; then
  makewhatis /system/usr/share/man;
fi

mount -o ro,remount /system/usr/share;
