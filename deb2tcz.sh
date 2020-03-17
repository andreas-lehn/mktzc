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

usage() {
    echo "usage: $0 [-h] [-e <file>] <deb-package>"
}

help() {
    usage
    echo "Make TinyCoreLinux extension form debian package <deb-package>."
    echo
    echo "  -h           Show this help message."
    echo "  -e <file>    Exclude file or directory <file> from TinyCoreLinux extension."
    echo "               Option -e can be specified multiple times."
}

excludes=""

while getopts e:h opt
do
    case $opt in
        e) excludes="$excludes $OPTARG" ;;
        h) help; exit 0 ;;
        ?) usage; exit 1 ;;
    esac
done
shift $((OPTIND-1))

debfile=$1
if [ -z "$debfile" ]
then
    echo "$0: Debian package missing."
    usage
    exit 1
fi

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

# remove files in excludes
for f in $excludes
do
    if [ -e "$filesdir/$f" ]
    then
        rm -rf "$filesdir/$f"
    else
        echo "$0: $f: no such file or directory"
    fi
done

# generate the file list of the extension
rm -f $extension.tcz.list
for f in $(cd $filesdir; find *)
do
    [ ! -d "$filesdir/$f" ] && echo $f >> $extension.tcz.list 
done

# squash the files together as an TinyCoreLinx extension
rm -f $extension.tcz
mksquashfs $filesdir $extension.tcz > /dev/null

# calculate the md5 sum
md5sum $extension.tcz > $extension.tcz.md5.txt

# clean up
rm -r $tempdir
