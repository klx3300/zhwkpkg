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

PKGFILE="$1"

INSTALLDIR=$(cat $SOURCEDIR/installpath)

echo Initiating installation process..

if [ -z $ZHWKPKG_TEMP_FOLDER ]
then
    TMPFOLDER='/tmp/zhwktmp'
else
    TMPFOLDER="$ZHWKPKG_TEMP_FOLDER"
fi

echo Selected temporary working folder is: $TMPFOLDER

if ! [ -r $PKGFILE ] 
then
    echo Package not found.
    exit 1
fi

# make the temporary folder..
mkdir $TMPFOLDER 2>/dev/null

# clear previous temporary content..
rm $TMPFOLDER/zhwkpkg-tmp.tar.bz2 2>/dev/null
rm -rf $TMPFOLDER/* 2>/dev/null

cp $PKGFILE $TMPFOLDER/zhwkpkg-tmp.tar.bz2
state_checker
tar jxvf $TMPFOLDER/zhwkpkg-tmp.tar.bz2 -C $TMPFOLDER/
state_checker
rm $TMPFOLDER/zhwkpkg-tmp.tar.bz2
# get package name
PKGNAME=$(ls $TMPFOLDER/)
PKGNAME=($PKGNAME) # format it into..
echo Package $PKGNAME
echo Checking package format..
if ! [ -e $TMPFOLDER/$PKGNAME/VERSION ]
then
    echo Package broken: version number file \'VERSION\' not exist.
    exit 1
fi
if ! [ -e $TMPFOLDER/$PKGNAME/MODULEFILE ]
then
    echo Package incomplete: modulefile \'MODULEFILE\' not exist. Continue..
fi
# PREPARE and CLEANUP is TOTALLY OPTIONAL. WILL NOT CHECK

PKGVER=$(cat $TMPFOLDER/$PKGNAME/VERSION)
if [ -d $INSTALLDIR/$PKGNAME-$PKGVER ]
then
echo Detected installed package with the same name and same version.
exit 1
fi

INSTALLDEST="$INSTALLDIR/$PKGNAME-$PKGVER"

# execute PREPARE
PREPARE="$TMPFOLDER/$PKGNAME/PREPARE"
if [ -e $PREPARE ]
then
    echo Starting PREPARE..
    chmod +x $PREPARE
    $PREPARE $TMPFOLDER/$PKGNAME $INSTALLDEST
    state_checker
else
    echo Skipped PREPARE..
fi

echo Copying files..
mkdir $INSTALLDEST
state_checker
cp -r $TMPFOLDER/$PKGNAME/* $INSTALLDEST/
state_checker

mkdir $INSTALLDIR/modulefiles 2>/dev/null

if [ -r $INSTALLDEST/MODULEFILE ]
then
    echo Building modulefile..
    awk "{gsub(/#%INSTALL_FOLDER%#/,\"$INSTALLDEST\")}1" $INSTALLDEST/MODULEFILE > $INSTALLDIR/modulefiles/$PKGNAME-$PKGVER
    state_checker
else
    echo Skipped modulefile..
fi

# execute CLEANUP
CLEANUP="$TMPFOLDER/$PKGNAME/CLEANUP"
if [ -e $CLEANUP ]
then
    echo Starting CLEANUP..
    chmod +x $CLEANUP
    $CLEANUP $INSTALLDEST
    state_checker
else
    echo Skipped CLEANUP..
fi

echo Everything done. No error detected.

