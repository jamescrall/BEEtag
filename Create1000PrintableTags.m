%% Example for generating 10 pdfs, each with 100 labeled BEETags in it
load masterCodeList.mat

ntags = 10; %How many rows and columns of tags to print? Will print ntags^2 tags (i.e. ntags = 10 produces an image with 100 tags)
    
f = figure('Visible', 'Off');
set(f, 'Position', [0 0 4000 4000])
for j = [0 100 200 300 400 500 600 700 800 900];
    %%
    for i = 1:(ntags^2)
        
        subplot(ntags,ntags,i);
        
        num = grand(j + i);
        
        im = createPrintableCode(num, 20);  
        
        imshow(im);
        text(-25, 180, num2str(num), 'FontSize', 8, 'Rotation', 90);
        text(185, 90, '->');
    end
    
    % Prints directly to a pdf (and therefore scalable) image of 100 tags
    % instead of printing to figure
    print(strcat(num2str(j), '-', num2str(j+99), 'keyed.pdf'), '-dpdf');
end