function R = locate16BitCodes(im, varargin)
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
%'sizeThresh' - one element vector sets the mimimum size threshold, two 
%   element vector sets the minimum and maximum size threshold. Only really
%   helps to clean out noise - start with a low number at first!
%   Default is a minimum threshold of 100
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
%'tagList'- option to add list of pre-specified valid tags to track. The 
%   taglist should be a vector of tag numbers that are actually in im.
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
% code: 16 bit binary code read from tag
%
% number: original identification number of tag
%
% frontX: X coordiante (in pixels) of tag "front"
%
% frontY: Y coordinate (in pixels) of tag "front"
%

%% Extract optional inputs, do initial image conversion, and display thresholded value

%Check for manually supplied 'vis' value
%strcmp, compares strings
%varagin, an input variable in a function definition statement that allows the function to accept any number of input arguments.
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

%Tag size threshold value
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
    BW = bradley(GRAY, smP, brT); %uses the external bradley.m function
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
% SD - I don't fully understand what this option does so just ignore it for
% now
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

%Marker size for displaying green points on potential tag corners
cornerSize = 10;

%% Find contiguous white regions
% The longest step in the script, takes ~10s for a 4K video frame
%   In a test image this produces 18,167 entries in R
% Centroid, center of mass of white blobs
% Area, calculates the area of each white blob
% BoundingBox, defines the smallest rectangle containing the region
% FilledImage, returns a binary image with all of the holes inside the
%   region filled in
R = regionprops(BW, 'Centroid','Area','BoundingBox','FilledImage');

%% Set size threshold for tags if supplied
if numel(sizeThresh) == 1
    %get rid of blobs smaller than the first value
    R = R([R.Area] > sizeThresh);
elseif numel(sizeThresh) == 2
    %gets rid of blobs larger than the second value
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
    %try & catch overrides the default error behaviours
    %SD - this must normally produce a MATLAB error that stops everything
    try
        %suppress warnings messages
        warning('off', 'all');
        %fitquad external function adapted from CALtag
        %isp, binary output if the blob has 4 corners
        %cnr, output of coordinates of the corner points
        %compares the bounding box and the filled image
        [isq,cnr] = fitquad( R(i).BoundingBox, R(i).FilledImage);
        %turn warnings back on
        warning('on', 'all');
        %save results 
        R(i).isQuad = isq;
    catch
        R(i).isQuad = 0;
        continue
    end
    
    if isq
        %save corner coords if it had 4 corners
        R(i).corners = cnr;
    end
end

%save only blobs that have 4 corners
R = R(logical([R.isQuad]));

%% Loop over all white regions that could be squares, and check for valid tags

for i=1:numel(R)
    %extract corner coords
    corners = R(i).corners;
    %reshape coords
    cornersP = [corners(2,:) ;corners(1,:)];
    tform = maketform('projective', cornersP',[ 0 0;  1 0;  1  1;  0 1]);
    %creates a 2D projective transformation that maps each point of cornerP
    %to corners with coordinates (0,0)(0,1)(1,0)(1,1)
    udata = [0 1];  vdata = [0 1];
    
    hold on
    
    for bb = 1:4
        
        if vis ==1
            plot(cornersP(1,bb), cornersP(2,bb),'g.', 'MarkerSize', cornerSize)
        end
        
    end
    
    %% Set up original coordinates in grid
    %the ideal tag grid is 6 squares across
    %   the black border is 1 square thick, so adds up to 2 across the tag
    %   + 4 squares of the code across = 6 squares
    x = [4.5/6 3.5/6 2.5/6 1.5/6];
    %this step defines the middle of the 4 code squares in 1 dimension
    xp = [repmat(x(1), 4, 1) ;repmat(x(2), 4, 1);repmat(x(3), 4, 1);repmat(x(4), 4, 1)];
    %repmat, repeat copies of an array
    %defines the middle point of each square in the grid, 2 dimensions
    P = [xp  repmat(x,1,4)']; 
    %full grid of proportional coordinates (0-1)
    f = [ 0 0;  0 1;  1  1;  1 0]; 
    %SD - f might be unused?
    pts = tforminv(tform,P); 
    %applies inverse spatial transformation (based on transformation in
    %tform) to the basic proportional coordinate grid
    pts = round(pts);
    %rounds values

    hold on; %allow to plot on exisitng figure window
    
    %Extract local pixel values around points
    ptvals = [];
    
    for aa = 1:numel(pts(:,1))
        cur = pts(aa,:);
        %extract first row of points
        cur = fliplr(cur);
        %flip array left to right
        try
            ptvals(aa) = BW(cur(1),cur(2));
            %save the binary value of each position in the grid
            
            %Comment line below in to use median of 9 adjacent pixels
            %instead of single pixel value
            %ptvals(aa) = median(reshape(BW((cur(1)-1):(cur(1)+1),(cur(2)-1):(cur(2)+1))',1,9));
        catch
            continue
        end
        
    end
    

    % Check pixel values for valid codes
    % Should have 16 pixel values
    if numel(ptvals) == 16
        
        %this is the default trackMode
        if trackMode == 0
            code = [ptvals(1:4);ptvals(5:8);ptvals(9:12);ptvals(13:16)];
            code = fliplr(code);
            [pass, code, orientation] = checkOrs16(code);
            %FUNCTION - checkOrs16
            %
            %number = bin2dec(num2str(code(1:12)));
            R(i).passCode = pass; %is it a code?
            R(i).code = code; 
            R(i).orientation = orientation;
        
        %skip this bit becasue i dont know what permissive trakcing is    
        elseif trackMode == 1
            [pass, code, orientation] = permissive16BitCodeTracking(imo, pts);
            R(i).passCode = pass; %yes it is a code
            R(i).code = code; %the 16 bit code in written in the correct orientation
            %e.g. 0000-0000-0001-0011 (1:12)=the code, (13:
            R(i).orientation = orientation; %orientation is either 1,2,3 or 4 and is used later to save the coordinates of the front of the tag
            %the values correspond to the number of times the grid was
            %rotated by 90 before the check matched the code
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
    R(i).number = bin2dec(num2str(R(i).code(1:12))); %Convert text representation of binary number to decimal number
    
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
    
    if isempty(R);
        disp('No Valid Tags Found');
    else
        R = R(ismember([R.number], validTagList));
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

R = rmfield(R, {'FilledImage', 'isQuad', 'passCode', 'orientation', 'BoundingBox', 'code'});

hold off;
%%