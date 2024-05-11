#!/bin/bash

if [ ! -d "/run/user/1000/gvfs/ftp:host=simonste.ch/map.simonste.ch/" ]; then
    echo "Mount FTP drive first!"
    exit 1
fi

rm build/web -r

flutter build web

sed -i 's/<base href="\/">//' build/web/index.html

if [ $? == 0 ]; then
    remote_dir="/run/user/1000/gvfs/ftp:host=simonste.ch/teambalancer.simonste.ch/"
    rsync -rv --delete --exclude='.git/' --exclude='api/' build/web/ $remote_dir
fi