#!/bin/sh


# name of the extension is the first positional paramter to the script
extension=${1:-tce}

# create a temporary directory
tempdir=$(mktemp -d)
if [ $? -ne 0 ]
then
    echo "$0: Can't create temp directory, exiting..."
    exit 1
fi

# read file names from stdin and add regular files to `files`
while read f
do
    if [ ! -d $f ]
    then
        files="$files $f"
    fi
done

# create a tar ball containing all files of the extension
tarball=$tempdir/$extension.tar.gz
tar czf $tarball $files

# generate the file list of the extension
tar tf $tarball > $extension.tcz.list

# put all the files of the extension into a folder to squash it later
filesdir=$tempdir/$extension
mkdir $filesdir
tar xf $tarball -C $filesdir

# squash the files together as an TinyCore extension
rm -f $extension.tcz
mksquashfs $filesdir $extension.tcz

# calculate the md5 sum
md5sum $extension.tcz > $extension.tcz.md5.txt

# clean up
rm -r $tempdir
