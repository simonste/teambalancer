#!/bin/bash

if [ ! -d "/run/user/1000/gvfs/ftp:host=simonste.ch/map.simonste.ch/" ]; then
    echo "Mount FTP drive first!"
    exit 1
fi

rm build/web -r

sed -i 's|teambalancer.simonste.ch/api-test|teambalancer.simonste.ch/api|' lib/data/backend.dart
flutter build web
sed -i 's|teambalancer.simonste.ch/api|teambalancer.simonste.ch/api-test|' lib/data/backend.dart

sed -i 's/<base href="\/">//' build/web/index.html

if [ $? == 0 ]; then
    remote_dir="/run/user/1000/gvfs/ftp:host=simonste.ch/teambalancer.simonste.ch/"
    rsync -rv --delete --exclude='.git/' --exclude='api/' --exclude='.well-known/' --exclude='api-test/' --exclude='backups/' build/web/ $remote_dir
fi
