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
%% Optional saving to overwrite stored codelist
 codeList = codeList(2:end,:);
% save('masterCodeList.mat', 'grand')
