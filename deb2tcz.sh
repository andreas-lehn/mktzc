#!/bin/sh
#
# This script converts a debian package (.deb) file into a TinyCoreLinux extension
# It takes the name of the .deb file as first parameter
# and assumes that the file follows the debian package file naming convention.
# It uses the first part of the name as the name for the TinyCoreLinux extension.
#
# Example:
# --------
#
# Given a debian package file `libunwind8_1.2.1-9_armhf.deb`.
# Then name of the extension will be `libunwind8`

debfile=$1
extension=$(echo $debfile | awk -F _ '{ print $1}')
tarballname=$(ar -t $debfile | grep data.tar)

# create a temporary directory
tempdir=$(mktemp -d)
if [ $? -ne 0 ]
then
    echo "$0: Can't create temp directory, exiting..."
    exit 1
fi

# extract the tarball from the debian file
tarball=$tempdir/$tarballname
ar -p $debfile $tarballname > $tarball

# put all the files of the extension into a folder to squash it later
filesdir=$tempdir/$extension
mkdir $filesdir
tar xf $tarball -C $filesdir

# generate the file list of the extension
for f in $(cd $filesdir; find *)
do
    if [ ! -d $filesdir/$f ]
    then
        echo $f >> $extension.tcz.list 
    fi
done

# squash the files together as an TinyCoreLinx extension
rm -f $extension.tcz
mksquashfs $filesdir $extension.tcz

# calculate the md5 sum
md5sum $extension.tcz > $extension.tcz.md5.txt

# clean up
rm -r $tempdir
