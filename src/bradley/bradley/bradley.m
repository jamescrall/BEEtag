%BRADLEY local thresholding.
%   BW = BRADLEY(IMAGE) performs local thresholding of a two-dimensional
%   array IMAGE with Bradley method. The key idea of the algorithm is that
%   every image's pixel is set to black if its brightness is T percent
%   lower than the average brightness of surrounding pixels in the window
%   of the specified size, otherwise it is set to white.
%      
%   BW = BRADLEY(IMAGE, [M N], T, PADDING) performs local
%   thresholding with M-by-N neighbourhood (default is 15-by-15). The 
%   default value for T is 10 and can be set in range 0..100. To deal with 
%   border pixels the image is padded with one of PADARRAY options (default 
%   is 'replicate').
%       
%   Example
%   -------
%       imshow(bradley(imread('eight.tif'), [125 125], 10));
%
%   See also PADARRAY, RGB2GRRAY.

%   Contributed by Jan Motl (jan@motl.us)
%   $Revision: 1.1 $  $Date: 2015/04/19 17:03:01 $

function output = bradley(image, varargin)
% Initialization
numvarargs = length(varargin);      % only want 3 optional inputs at most
if numvarargs > 3
    error('myfuns:somefun2Alt:TooManyInputs', ...
     'Possible parameters are: (image, [m n], T, padding)');
end
 
optargs = {[15 15] 10 'replicate'}; % set defaults
 
optargs(1:numvarargs) = varargin;   % use memorable variable names
[window, T, padding] = optargs{:};


% Convert to double
image = double(image);

% Local mean
mean = averagefilter(image, window, padding);

% Initialize the output to white color
output = true(size(image));

% Set a pixel to black if the image brightness 
% is below (100-T)% of the average neighbourhood brightness
output(image <= mean*(1-T/100)) = 0;

