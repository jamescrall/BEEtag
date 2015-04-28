grand = [];
codesFinal = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
codeList = reshape(createCode(1)', 1, 25);

for dd = 1:(2^15-1) %Highest possible number is 32767 with 15 bits
    %%
    test = createCode(dd);
    
    [pass code or codes] = checkOrs25(test);
    
    if pass == 1
                
        %Find pairwise distances between all stored codes and current code
        
        distM = zeros(size(codesFinal,1),1);
        
        for ee = 1:numel(distM)
            distM(ee) = sum(abs(codesFinal(ee,:) - code));
        end
        
        if  min(distM) > 2
            grand = [grand dd];
            codesFinal = [codesFinal ; codes];
            codeList = [codeList; reshape(test', 1, 25)];
        end
    end
    if mod(dd, 1000) == 0
        disp(dd);
    end
end
%%
codeList = codeList(2:end,:);
save('masterCodeList.mat', 'grand')
%% Example for generating codes
for i = 1:100
    
    subplot(10,10,i)
    code = codeList(i,:);
    im = reshape(code,5,5);
    im = padarray(im,[1 1], 1, 'both');
    
    im = padarray(im, [1 1],'both');
    imshow(im)
    %title(grand(i));
    
    
end

set(gcf,'position', [-1651 -78 1523 1007])