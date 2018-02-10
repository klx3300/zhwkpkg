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
# execute zhwkpkg-get to download the package..
echo "Downloading the package.."
$SOURCEDIR/zhwkpkg-get.sh $1
state_checker
echo "Deploying the package.."
$SOURCEDIR/zhwkpkg-deploy.sh $(pwd)/$1.tar.bz2
state_checker
echo "Cleaning up.."
rm $(pwd)/$1.tar.bz2
