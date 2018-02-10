#!/bin/bash

state_checker(){
    if [ $? -gt 0 ]
    then
        echo "Previous operation unsuccessful."
        exit 1
    fi
    return 0
}
OK(){
    printf "[    OK    ]\n"
}
WARN(){
    printf "[   WARN   ]\n"
}
FAIL(){
    printf "[   FAIL   ]\n"
}

GOOD(){
    printf "[   GOOD   ]\n"
}
SKIP(){
    printf "[   SKIP   ]\n"
}

DIR="$1"

if ! [ -d $DIR ]
then
    echo "Specified directory not exist."
    exit 1
fi

printf "Checking VERSION -- "

if ! [ -e $DIR/VERSION ]
then
    FAIL
    exit 1
fi
OK

printf "Checking MODULEFILE -- "

if ! [ -e $DIR/MODULEFILE ]
then
    WARN
    echo "MODULEFILE not exist. Continue.."
else
    cat $DIR/MODULEFILE | grep "\#\%INSTALL_FOLDER\%\#"
    if [ $? -gt 0 ]
    then
        WARN
        echo "MODULEFILE did not contain buildable content. Continue.."
    else
        OK
    fi
fi

printf "Checking PREPARE -- "
if ! [ -e $DIR/PREPARE ]
then
    SKIP
else
    GOOD
fi

printf "Checking CLEANUP -- "
if ! [ -e $DIR/CLEANUP ]
then
    SKIP
else
    GOOD
fi

echo "Satisfactory. Start packaging.."
PWD="$(pwd)"
cd $DIR/../
tar jcvf $PWD/package.tar.bz2 $(basename $DIR)
state_checker
cd $PWD
echo "Done. saved to ./package.tar.bz2"