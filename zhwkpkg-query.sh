#!/bin/bash

SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LISTPATH="$(cat $SOURCEDIR/serveraddr)/pkglist.lst"

STATUSCODE="$(curl -I $LISTPATH 2\>/dev/null | head -n 1 | cut -d$\' \' -f2)"

if [ $? -gt 0 ]
then
    echo "SERVER BOOMED!"
    exit 1
fi

if [ $STATUSCODE != "200" ]
then
    echo "Not a valid zhwkpkg distribution server."
    exit 1
fi

echo "Downloading pkglist content.."

curl $LISTPATH 2>/dev/null
