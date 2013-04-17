About
=====
xarfs is an OSXFUSE-based filesystem that mounts xar archive files as a read-only filesystem. This software is proof-of-concept, and is not a finished product in any respect. xarfs is open source, licensed under the two-clause BSD license.


Requirements
============
xarfs has the following requirements:

* Mac OS X (tested on 10.8)
* [FUSE for OSX](http://osxfuse.github.io). xarfs will not work without it.


How to Use
==========
* To install xarfs, copy the xarfs application from the disk image to your favorite Applications directory.
* To mount a xar file with xarfs, drag the archive onto the xarfs application icon. It may be necessary to open xarfs, and then drop the archive onto its dock icon. The xar file will mount as a read-only filesystem.
* To remove xarfs, simply delete the application.


Known Limitations
=================
* xarfs provides a read-only filesystem
* xarfs decompresses files in memory. This means you must have as much free memory as any file you attempt to access.
* xarfs can only mount one xar file at a time
* xarfs has a rather cumbersome interface
* error reporting is somewhat lacking
* The code is pretty terrible
