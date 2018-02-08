#!/bin/bash

SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

INSTALLPATH="$(cat $SOURCEDIR/installpath)"

for path in $INSTALLPATH/*; do
    [ -d "${path}" ] || continue
    BASE="$(basename $path)"
    if [ $BASE != "modulefiles" ]
    then
        echo $BASE
    fi
done
