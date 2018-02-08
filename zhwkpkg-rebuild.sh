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
INSTALLPATH="$(cat $SOURCEDIR/installpath)"
MODULEPATH="$(cat $SOURCEDIR/installpath)/modulefiles"
# iterating directories
for path in $INSTALLPATH/*; do
    [ -d "${path}" ] || continue # skip non-directories
    if [ $(basename $path) = "modulefiles" ]
    then
        continue
    fi
    echo Rebuilding $(basename $path)
    INSTALLDEST=$path
    awk "{gsub(/#%INSTALL_FOLDER%#/,\"$INSTALLDEST\")}1" $INSTALLDEST/MODULEFILE > $MODULEPATH/$(basename $path)
    state_checker
done

echo Operation completed.