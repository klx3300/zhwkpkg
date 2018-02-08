#!/bin/bash

SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LISTPATH="$(cat $SOURCEDIR/serveraddr)/pkglist.lst"

STATUSCODE="$(curl -I -X GET $LISTPATH 2\>/dev/null | head -n 1 | cut -d$\' \' -f2)"

if [ $? -gt 0 ]
then
    echo "SERVER BOOMED!"
fi

if [ $STATUSCODE != "200" ]
then


exit 1