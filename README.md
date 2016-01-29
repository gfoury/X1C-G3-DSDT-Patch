# X1C-G3-DSDT-Patch

This is a collection of DSDT/SSDT patches and tools for the Lenovo X1 Carbon Gen 3 (20BS, 20BT) 2015 laptop.

## Downloading

This repository depends on one of RehabMan's repositories as a git submodule. After you've cloned this repository, run

```
git submodule init
git submodule update
```

to download that module. 

## Patching

Patching does not need to be run on an X1c, but you do need the ACPI files from your X1c.

To generate your ACPI files, boot your X1c with Clover from a USB drive, and press `F4`. This will dump a bunch of files in `YOURDISK/EFI/CLOVER/ACPI/origin/`. Copy those files into `native_clover/origin/` in this repository's directory. After copying, run the command `sh disassemble.sh` to generate the .dsl files to patch.

Most of the SSDTs do not need to be modified. Unmodified SSDTs are copied without disassembly/reassembly.

To run the patcher, run `make`.

Copy `X1C-G3-DSDT-Patch` to the destination machine.

## Installing patched files

Copy `build/*.aml` to the `EFI/CLOVER/ACPI/patched` directory.

Make sure that your Clover plist has `DropOem` set. 

## Credits

jcsnider wrote the guide for the X1 Carbon Gen 3, and this patcher just automates a small portion of his work. See http://www.tonymacx86.com/yosemite-laptop-guides/162391-guide-2015-x1-carbon-yosemite.html

RehabMan wrote....nearly everything else. :-)
