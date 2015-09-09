function R = locateCodes(im, varargin)
%locates optical tags and spits out regionprops info for all tags
%
% Input form is locateCodes(im, varargin)
%
% Required input:
%
%'im' is an image containing tags, can be rgb or grayscale - currently not
%supported to directly input
%
%
% Optional inputs include:
%
%'colMode' - determines whether to show gray (1)  or bw (0) image, 2 is
%   rgb, anything else (i.e. 3) plots on whatever background is already plotted
%
%'thresh' - thresholding value to turn grayscale into a binary image,
%   ranges from 0 to 1, default is to calculate threshold value automatically
%
%'vis' - whether or not to visualize results, 0 being no visualization, 1
%   being visualization. Default is visualization
%
%'sizeThresh' - size threshold for tags in pixels, highly specific to camera
%   and capture system. Only really helps to clean out noise - start with a
%   low number at first! Default is 100
%
%'robustTrack' - whether or not to identify binary values for tracking codes
%   from black and white binary image, or to track over a range of values from
%   an original grayscale image with intelligent thresholding. The latter
%   produces more false positives, and it is recommended to only use this in
%   conjunction with a pre-specificed list of tags for tracking. Adding size
%   restrictions on valied tags is also recommended. When using this option,
%   you must specify a grayscale image to take the pixel values from (can
%   be the same as 'im');
%
%'tagList'- option to add list of pre-specified valid tags to track.
%   Output from any other tags found in the picture is ignored
%
%'threshMode' - options for black-white thresholding. Default is 0, which
%   uses supplied threshold and above techniques. Alternative option is
%   Bradley local adaptive thresholding, which helps account for local
%   variation in illumination within the image.
%
% 'bradleyFilterSize' - two element vector defining the X and Y
%   (respectively) size of locally adaptive filter. Only supply when
%   'threshMode' is 1 (using adaptive thresholding).
%
% 'bradleyThreshold' - black-white threshold value after local filtering.
%   Default value is 3, lower values produce darker images, and vice versa.
%
%
%
% Outputs are:
% Area: area of tag in pixel:
%
% Centroid: X and Y coordinates of tag center
%
% Bounding Box: Boundig region of image containing tag
%
% corners: Coordinates of four calculated corner points of tag
%
% code: 25 bit binary code read from tag
%
% number: original identification number of tag
%
% frontX: X coordiante (in pixels) of tag "front"
%
% frontY: Y coordinate (in pixels) of tag "front"
%

%% Extract optional inputs, do initial image conversion, and display thresholded value

%Check for manually supplied 'vis' value
v = strcmp('vis', varargin);

if sum(v) == 0
    vis = 1;
else
    vis = cell2mat(varargin(find(v == 1) + 1));
end


%Check for manually supplied 'colMode' argument
colM = strcmp('colMode', varargin);

if sum(colM) == 0
    colMode = 0;
else
    colMode = cell2mat(varargin(find(colM == 1) + 1));
end


%tag size threshold value
tagTh = strcmp('sizeThresh', varargin);

if sum(tagTh) == 0
    sizeThresh = 100;
else
    sizeThresh = cell2mat(varargin(find(tagTh == 1) + 1));
end


% threshMode value
threshM = strcmp('threshMode', varargin);

if sum(threshM) == 0
    threshMode = 0;
else
    threshMode = cell2mat(varargin(find(threshM == 1) + 1));
end


% If using adaptive thresholding, define filter size
bradleyP = strcmp('bradleyFilterSize', varargin);

if sum(bradleyP) == 0
    smP = [15 15];
else
    smP = cell2mat(varargin(find(bradleyP == 1) + 1));
end


% If using adaptive thresholding, define threshold value
bradleyT = strcmp('bradleyThreshold', varargin);
if sum(bradleyT) == 0
    brT = 3;
else
    brT = cell2mat(varargin(find(bradleyT == 1) + 1));
end


% Convert image to grayscale if RGB
if ndims(im) > 2
    GRAY = rgb2gray(im);
elseif ndims(im) == 2
    GRAY = im;
end


%Check for manually supplied threshold value
th = strcmp('thresh', varargin);

if sum(th) == 0
    thresh=graythresh(GRAY);
else
    thresh = cell2mat(varargin(find(th == 1) + 1));
end


%Do B-W conversion
if threshMode == 0
    BW=im2bw(GRAY, thresh);
elseif threshMode  == 1
    BW = bradley(GRAY, smP, brT);
end


%Display requested image
if colMode == 1 && vis == 1
    imshow(GRAY);
end

if colMode == 0 && vis== 1
    imshow(BW);
end

if colMode == 2 && vis == 1
    imshow(im);
end


% Define tracking mode
trackM = strcmp('robustTrack', varargin);

if sum(trackM) == 0
    trackMode = 0;
else
    trackMode = 1;
    imo = cell2mat(varargin(find(trackM == 1) + 1));
end


% Define optional list of valid codes
listM = strcmp('tagList', varargin);

if sum(listM) == 0
    listMode = 0;
    validTagList = [];
else
    listMode = 1;
    validTagList = cell2mat(varargin(find(listM == 1) + 1));
end


%Marker size for green points on potential tag corners
cornerSize = 10;

%% Find contiguous white regions
R = regionprops(BW, 'Centroid','Area','BoundingBox','FilledImage');

%% Set size threshold for tags if supplied

if numel(sizeThresh) == 1
    
    R = R([R.Area] > sizeThresh);
    
elseif numel(sizeThresh) == 2
    
    R =  R([R.Area] > sizeThresh(1) & [R.Area] < sizeThresh(2));
    
else
    
    disp('sizeThresh has an incorrect numbers of elements: Please supply either a single number or a two-element numeric vector');
    return;
    
end

if isempty(R)
    
    disp('No sufficiently large what regions detected - try changing thresholding values for binary image threshold (thresh) or tag size (sizeThresh)');
    return
    
end

%% Find white regions that are potentially tags
for i = 1:numel(R)
    
    try
        warning('off', 'all');
        [isq,cnr] = fitquad( R(i).BoundingBox, R(i).FilledImage);
        warning('on', 'all');
        R(i).isQuad = isq;
        
    catch
        
        R(i).isQuad = 0;
        continue
        
    end
    
    if isq
        
        R(i).corners = cnr;
        
    end
end

R = R(logical([R.isQuad]));

%% Loop over all white regions that could be squares, and check for valid tags

if isempty(R)
    
    disp('No potentially valid tag regions found')
    return
    
end

for i=1:numel(R)
    
    corners = R(i).corners;
    cornersP = [corners(2,:) ;corners(1,:)];
    tform = maketform('projective', cornersP',[ 0 0;  1 0;  1  1;  0 1]);
    udata = [0 1];  vdata = [0 1];
    
    hold on
    
    for bb = 1:4
        
        if vis ==1
            plot(cornersP(1,bb), cornersP(2,bb),'g.', 'MarkerSize', cornerSize)
        end
        
    end
    
    %Set up original coordinates in grid
    x = [5.5/7 4.5/7 3.5/7 2.5/7 1.5/7];
    xp = [repmat(x(1), 5, 1) ;repmat(x(2), 5, 1);repmat(x(3), 5, 1);repmat(x(4), 5, 1);repmat(x(5), 5, 1)];
    P = [xp  repmat(x,1,5)'];
    f = [ 0 0;  0 1;  1  1;  1 0];
    pts = tforminv(tform,P);
    pts = round(pts);
    R(i).pts = pts;

    hold on;
    
   
    %Extract local pixel values around points
    ptvals = [];
    
    for aa = 1:numel(pts(:,1))
        
        cur = pts(aa,:);
        cur = fliplr(cur);
        
        try
            
            ptvals(aa) = BW(cur(1),cur(2));
            
            %Comment line below in to use median of 9 adjacent pixels
            %instead of single pixel value
            %ptvals(aa) = median(reshape(BW((cur(1)-1):(cur(1)+1),(cur(2)-1):(cur(2)+1))',1,9));
            
        catch
            
            continue
            
        end
        
    end
    

    % Check pixel values for valid codes
    if numel(ptvals) == 25
        
        if trackMode == 0
            
            code = [ptvals(1:5);ptvals(6:10);ptvals(11:15);ptvals(16:20);ptvals(21:25)];
            code = fliplr(code);
            [pass code orientation] = checkOrs25(code);
            %number = bin2dec(num2str(code(1:15)));
            R(i).passCode = pass;
            R(i).code = code;
            R(i).orientation = orientation;
            
        elseif trackMode == 1
            
            [pass code orientation] = permissiveCodeTracking(imo, pts);
            R(i).passCode = pass;
            R(i).code = code;
            R(i).orientation = orientation;
            
        end
        
    else
        R(i).passCode = 0;
        R(i).code = [];
        R(i).orientation = NaN;
    end
    
    
    
    
end


%% Remove invalid tags and find tag front
R = R([R.passCode]==1);


% Tag orientation
for i=1:numel(R)
    %%
    R(i).number = bin2dec(num2str(R(i).code(1:15)));
    
    %Plot the corners
    corners = R(i).corners;
    cornersP = [corners(2,:) ;corners(1,:)];
    tform = maketform('projective', cornersP',[ 0 0;  1 0;  1  1;  0 1]);
    udata = [0 1];  vdata = [0 1];
    
    
    %%
    or = R(i).orientation;
    if or == 1
        ind = [1 2];
    elseif or == 2
        ind = [2 3];
    elseif or ==3
        ind = [3 4];
    elseif or ==4
        ind = [1 4];
    end
    
    frontX = mean(cornersP(1,ind));
    frontY = mean(cornersP(2,ind));
    
    R(i).frontX = frontX;
    R(i).frontY = frontY;
    %
end

%% If supplied, remove codes that aren't part of supplied valid tag list

if ~isempty(validTagList)
    
    R = R(ismember([R.number], validTagList));
    
    if isempty(R);
        disp('No Valid Tags Found');
    end
    
end


%% Optional code visualization

if vis==1
    for i = 1:numel(R)
        corners = R(i).corners;
        cornersP = [corners(2,:) ;corners(1,:)];
        text(R(i).Centroid(1), R(i).Centroid(2), num2str(R(i).number), 'FontSize',30, 'color','r');
        hold on
        for bb = 1:4
            plot(cornersP(1,bb), cornersP(2,bb),'g.', 'MarkerSize', cornerSize)
        end
        
        plot(R(i).frontX, R(i).frontY, 'b.', 'MarkerSize', cornerSize);
    end
end

R = rmfield(R, {'FilledImage', 'isQuad', 'passCode'});
hold off;
%%