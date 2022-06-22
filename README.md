# Code128Reader

## Overview

The following program reads Code128C barcodes saved as 24-bit bitmap images. It is written for RISC-V, x86 and x86_64 architectures.

## Usage

**RISC-V**: running Code128Reader on RISC-V architecture requires a special simulator called RARS, which is included inside RISC-V folder. To be able to run it, you need to have Java installed on your system. [More information about RARS can be found here.](https://github.com/TheThirdOne/rars).

After assembling and running the program, it asks for the path to the image to it. After that the program returns the decoded value of the barcode.

**x86 and x86_64**: those versions are already compiled and ready to launch. In order to launch the program, type:

`code128Reader.exe [path to the image]`

After running this command, the program returns the decoded value of the barcode.

## Download

View releases in order to download proper executables for x86 or x86_64 architectures for Unix systems or Windows.
