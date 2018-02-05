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

PKGNAME="$1"

INSTALLDIR="$(cat $SOURCEDIR/installpath)"

if ! [ -d $INSTALLDIR/$PKGNAME ]
then
    echo "Selected package did not exist."
    exit 1
fi

rm $INSTALLDIR/modulefiles/$PKGNAME 2>/dev/null
rm -rf $INSTALLDIR/$PKGNAME

state_checker

echo "Removed."