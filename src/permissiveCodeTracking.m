function [pass code orientation number] = permissiveCodeTracking(imo, pts)

%Inputs:
%  imo = original image to get values from, must be RGB or grayscale iamge
%
%%


ptvals = [];
for aa = 1:numel(pts(:,1))
    cur = pts(aa,:);
    cur = fliplr(cur);
    
    ptvals(aa) = imo(cur(1),cur(2));
    %Average over nine pixels
    %ptvals(aa) = median(reshape(BW((cur(1)-1):(cur(1)+1),(cur(2)-1):(cur(2)+1))',1,9));
    %Comment in to use only average
    
end

codeo = [ptvals(1:5);ptvals(6:10);ptvals(11:15);ptvals(16:20);ptvals(21:25)];
codeo = fliplr(codeo);
codesc = codeo - min(min(codeo));
codesc = codesc/max(max(codesc));
threshes = 0.5;
codedat = struct();

%%
for j = 1:numel(threshes);
    %%
    codec = codesc > threshes(j);
    [pass code orientation] = checkOrs25(codec);
    codedat(j).pass = pass;
    codedat(j).code = code;
    codedat(j).orientation = orientation;
end

codedat = codedat([codedat.pass] == 1);
%%
if ~isempty(codedat)
    %% Subset to the most common number
    for j = 1:numel(codedat)
        codedat(j).number = bin2dec(num2str(codedat(j).code(1:15)));
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

%%

