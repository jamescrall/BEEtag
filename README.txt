beeTag Software Instructions ----------------------


REQUIREMENTS

-Matlab (tested with R2014b) with Image Processing Toolbox



INSTALLATION

1. Download all functions and files from available on github from
https://github.com/jamescrall/idBEE/ and add to matlab path (making sure to "Add with
Subfolders")

2. Run trackingExample.m to check functionality



INSTRUCTIONS FOR OPERATION

1. The main interactive function is locateCodes.m, a function which finds beeTags in an
image based on users inputs and returns the tag's identity ('number'), location, and
orientation as matlab structure. For input options and output details, see "help
locateCodes".

2. CreatePrintableCode and Create100PrintableCodes.m are a function and example
(respectively), of how to generate beeTags in a printable format. CreatePrintable Codes
generates the 100tags.pdf image in the src folde, which is print-ready and contains the
first 100 usable codes. That script can be modified to use more than a hundred codes,
drawing them from the "grand" object in "masterCodeList.mat"


CONTACT james.crall@gmail.com with any questions