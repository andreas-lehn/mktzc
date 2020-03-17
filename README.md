mktzc
=====

Tools to ease the creation of TinyCoreLinux extensions.


mktcz.sh
--------

`mktcz.sh` is a script that reads file names from `stdin` 
and creates an extension containing these files.
It takes the name of the extension as first parameter.
If no name is given it takes `tce` as the name of the extension.

The script is useful if you have the files that you want to put into an extension already installed on the system.
Then it is best to create a file list of these files and `cat` this list into the script:

    cat filelist | mktcz myextension

This will create the files

    myextension.tcz
    myextension.tcz.list
    myextension.tcz.md5.txt

The script ignores directories.
So you do not have to filter them out.

Most packages that can be build with the typical `automake` process have a make target `install` 
that installs the package on the sytem.
[TinyCoreLinux Forum](http://forum.tinycorelinux.net/index.php?topic=20215.0)
explains how to find out which files were installed:

    $ touch mymarker
    $ sudo make install
    $ sudo find / -not -type 'd' -cnewer mymarker | grep -v "\/proc\/" | grep -v "^\/sys\/" | tee files

After this sequence you have the files installed by the package in the file `files`.
You can edit this file to shape the package.
Then you can you `mktcz.sh` to build the extension:

    cat files | mktcz.sh extension

Sometimes I want to transfer debian packages installed on a raspbian system to piCore.
Therefore `mktcz.sh` is also useful.
`dpkg -L` lists the files that belong to a debian package.
So you can create a TinyCoreLinux extension easily:

    dpkg -L package | mktcz.sh package


deb2tcz.sh
----------

With `deb2tcz.sh` you can create TinyCoreLinux extensions from debian packages without the need to install them.
You can simply download the `.deb` file from repository and convert it.
If you are on a raspbian system you can download the `.deb` file of the `libunwind8` package with

    apt download libunwind8

or simply with a web browser.

    deb2tcz.sh libunwind8_1.2.1-9_armhf.deb

will create a TinyCoreLinux extension `libunwind8.tcz` that can be installed on a piCore system.


Resources
---------

