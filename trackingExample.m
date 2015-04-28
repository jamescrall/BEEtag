%Example to locate and identify visual barcodes within a picture
%Remember to add folder with code to your matlab path

%Read in example file
im = imread('scaleExample.png');
figure(1); 
subplot(2,2,1);
imshow(im);
title('Original image 1');

%Locate codes using the default values
subplot(2,2,2);
codes = locateCodes(im)
title('Tracked image 1');


%Read in second example file
im2 = imread('scaleExample2.png');
subplot(2,2,3);
imshow(im2);
title('Original image 2');

%Locate codes in the image using some manual input values instead of
%defaults
subplot(2,2,4);
codes2 = locateCodes(im2, 'colMode', 1, 'thresh', 0.2)
title('Tracked image 2');

%look at 'help locateCodes' to figure out what these 
%parameters are - most important for functionality is the thresholding
%mode/value, other stuff is just useful visualizing for error-checking,
%etc.

%The id number will show up in the picture in red if vis==1, otherwise it
%will show up in the codes structure (i.e. type 'codes.number')
