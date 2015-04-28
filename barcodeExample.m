%Example to locate and identify visual barcodes within a picture
%Remember to add folder with code to your matlab path

%Read in example file
im = imread('scaleExample.png');

%Look for codes
codes = locateCodes(im, 1, 0.5, 1, 1, 100); 

%look at 'help locateCodes' to figure out what these 
%parameters are - most important for functionality is the thresholding
%mode/value, other stuff is just useful visualizing for error-checking,
%etc.

%The id number will show up in the picture in red if vis==1, otherwise it
%will show up in the codes structure (i.e. type 'codes.number')
