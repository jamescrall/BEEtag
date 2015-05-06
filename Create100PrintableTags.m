%% Example for generating a jpeg with 100 tags

load masterCodeList.mat

ntags = 10; %How many rows and columns of tags to print? Will print ntags^2 tags (i.e. ntags = 10 produces an image with 100 tags)

f = figure('Visible', 'Off');
  
for i = 1:(ntags^2)
    
    subplot(ntags,ntags,i);
    
    num = grand(i);    
 
    im = createPrintableCode(num, 20);
    
    imshow(im);
end

% Prints directly to a pdf (and therefore scalable) image of 100 tags
% instead of printing to figure
print('100tags.pdf', '-dpdf');