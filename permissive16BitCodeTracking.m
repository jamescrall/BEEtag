function [pass code orientation number] = permissiveCodeTracking(imo, pts)

%Inputs:
%  imo = original image to get values from, must be RGB or grayscale iamge
%  pts = the coordinates of the central point of each square on the 4x4
%  grid
%%

ptvals = zeros(16,1);
%loop through all rows of pts
for aa = 1:numel(pts(:,1))
    cur = pts(aa,:); %extract all columns of first row
    cur = fliplr(cur); %flip array left to right
    
    ptvals(aa) = imo(cur(1),cur(2)); %extract the pixel values from image at the coordinates from cur
    %Average over nine pixels
    %ptvals(aa) = median(reshape(BW((cur(1)-1):(cur(1)+1),(cur(2)-1):(cur(2)+1))',1,9));
    %Comment in to use only average
    %ptvals now a list of pixel values
end

codeo = [ptvals(1:4),ptvals(5:8),ptvals(9:12),ptvals(13:16)]; %restructure into a 4x4 grid
codeo = fliplr(codeo); %flip array left to right
codesc = codeo - min(min(codeo));
codesc = codesc/max(max(codesc));
threshes = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9] ;
codedat = struct();

%%
for j = 1:numel(threshes)
    %%
    codec = codesc > threshes(j);
    [pass code orientation] = checkOrs16(codec);
    codedat(j).pass = pass;
    codedat(j).code = code;
    codedat(j).orientation = orientation;
end

codedat = codedat([codedat.pass] == 1);
%%
if ~isempty(codedat)
    %% Subset to the most common number
    for j = 1:numel(codedat)
        codedat(j).number = bin2dec(num2str(codedat(j).code(1:12)));
    end
    codedat = codedat([codedat.number] == mode([codedat.number])); %Remove any outlier numbers
    
    %% Now send out data from that number
    pass = 1;
    code = codedat(1).code;
    orientation = codedat(1).orientation;
    number = codedat(1).number;
    
elseif isempty(codedat)
    pass = 0;
    code = [];
    orientation = [];
end
    
end

%%

