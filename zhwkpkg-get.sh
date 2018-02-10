#!/bin/bash

SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

state_checker(){
    if [ $? -gt 0 ]
    then
        echo "Previous operation unsuccessful."
        exit 1
    fi
    return 0
}

PKGPATH="$(cat $SOURCEDIR/serveraddr)/$1.tar.bz2"

STATUSCODE="$(curl -I $PKGPATH 2>/dev/null | head -n 1 | cut -d$' ' -f2)"

if [ $? -gt 0 ]
then
    echo "SERVER BOOMED!"
    exit 1
fi

if [ $STATUSCODE != "200" ]
then
    echo "Not a successful request. Please note that no redirect here permitted."
    echo "Error code is HTTP $STATUSCODE."
    exit $STATUSCODE
fi

echo Downloading package using cURL..

curl $PKGPATH > $(pwd)/$1.tar.bz2

state_checker
