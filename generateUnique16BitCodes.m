grand = [];
codesFinal = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
codeList = reshape(create16BitCode(1)', 1, 16);

for dd = 1:(2^12-1) %Highest possible number is 4096 with 12 bits
    %%
    test = create16BitCode(dd);
    
    [pass, code, or, codes] = checkOrs16(test);
    
    if pass == 1
                
        %Find pairwise distances between all stored codes and current code
        
        distM = zeros(size(codesFinal,1),1);
        
        for ee = 1:numel(distM)
            distM(ee) = sum(abs(codesFinal(ee,:) - code));
        end
        
        if min(distM) > 2
        %if  min(distM) > 6  %%Comment in to generate "robustCodeList"
            grand = [grand dd];
            codesFinal = [codesFinal ; codes];
            codeList = [codeList; reshape(test', 1, 16)];
        end
    end
    
    if mod(dd, 1000) == 0
        disp(dd);
    end
end
%% Optional saving to overwrite stored codelist
 codeList = codeList(2:end,:);
 %save('master16BitCodeList.mat', 'grand');
 %save('masterCodeList.mat', 'grand');
 %save('robustCodeList.mat', 'grand')
