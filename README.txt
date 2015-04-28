idBEE Software Instructions 
----------------------


REQUIREMENTS

-Matlab (tested with R2014b) with Image Processing Toolbox



INSTALLATION

1. Download all functions and files from available on github from
https://github.com/jamescrall/idBEE/ and add to matlab path

2. Run trackingExample.m to check functionality



INSTRUCTIONS FOR OPERATION

1. The main interactive function is locateCodes.m, a function which finds idBEE tags in an
image based on users inputs and returns the tag's identity ('number'), location, and
orientation as matlab structure. For input options and output details, see "help
locateCodes".

2. CreatePrintableCode and visualizeidBEEtagsExample.m are a function and example
(respectively), of how to generate idBEE tags in a printable format.


CONTACT james.crall@gmail.com with any questions