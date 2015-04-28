load masterCodeList.mat

%% Visualize single code
num = 11;    
 
    im = createPrintableCode(num);
    
    imshow(im)
    %title(grand(i));
    
%% Example for generating several codes

for i = 1:100
    subplot(10,10,i);
    
    num = grand(i);    
 
    im = createPrintableCode(num);
    
    imshow(im)
end