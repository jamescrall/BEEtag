idBEE Software Package

*Software has been tested on Matlab R2014b.

INSTALLATION

1. Download all functions available on github and add to matlab path

2. Run barcodeExample.m to check functionality


OPERATION
1. The main interactive function is locateCodes.m, a function which finds idBEE tags in an
image based on users inputs and returns the tag's identity, location, and orientation.
(CheckCode 25.m, checkOrs25.m,createCode, and fitquad.m, and masterCodeList.mat are all
dependencies of this main function).

2. CreatePrintableCode and visualizeidBEEtagsExample.m are a function and example,
respectively, of how to generate idBEE tags in a printable format.

3. See "help locateCodes" in Matlab for information on various function inputs to
"locateCodes" function