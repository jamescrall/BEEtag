# BEEtag Software Instructions


## REQUIREMENTS

Matlab (most recently tested with R2023a)
Image Processing Toolbox
Statistics and Machine Learning Toolbox


## INSTALLATION

1. Download all functions and files from available on github from
https://github.com/jamescrall/BEEtag/ and add to matlab path (making sure to "Add with
Subfolders")

2. Run trackingExample.m to check functionality

## TROUBLESHOOTING
If you're hitting an error on the trackingExample.m script, check the following:

1. First, check that all the subfolders of the BEEtag repository are added to your Matlab path. (check in 'Home' , 'Set Path')

2. Confirm that you have the Image Processing and Statistics and Machine Leanrning Toolboxes installed, and if not install these

## USAGE

1. The main interactive function is locateCodes.m, a function which finds beeTags in an
image based on users inputs and returns the tag's identity ('number'), location, and
orientation as matlab structure. For input options and output details, see "help
locateCodes".

2. CreatePrintableCode and Create100PrintableCodes.m are a function and example
(respectively), of how to generate BEEtags in a printable format. CreatePrintable Codes
generates the 100tags.pdf image in the src folde, which is print-ready and contains the
first 100 usable codes. That script can be modified to use more than a hundred codes,
drawing them from the "grand" object in "masterCodeList.mat"



## CONTACT 
contact james.crall@wisc.edu with any questions
