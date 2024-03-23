#!/bin/bash

if [ ! -d "/run/user/1000/gvfs/ftp:host=simonste.ch/map.simonste.ch/" ]; then
    echo "Mount FTP drive first!"
    exit 1
fi

rm build/web -r

flutter build web

sed -i 's/<base href="\/">//' build/web/index.html

if [ $? == 0 ]; then
    echo "replace content on server"
    rm /run/user/1000/gvfs/ftp:host=simonste.ch/httpdocs/teambalancer/* -r
    cp build/web/* /run/user/1000/gvfs/ftp:host=simonste.ch/httpdocs/teambalancer/ -r
fi