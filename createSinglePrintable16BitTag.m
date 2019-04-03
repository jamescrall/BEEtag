%% Example for generating 10 separated high resolution jpegs for single tags
load master16BitCodeList.mat

ntags = 1; %How many tags to print?
    
f = figure('Visible', 'Off'); %Tells the figure not to print to the screen, so that resoluiton won't be limited by screen size
set(f, 'Position', [0 0 4000 4000])

    for i = 1:ntags
        pwd
        
        num = grand(i);
        
        im = createPrintable16BitCode(num, 40);
        
        imshow(im);
        text(-25, 150, num2str(num), 'FontSize', 30, 'Rotation', 90);
        text(380, 180, '->', 'FontSize', 30);
        print(strcat(num2str(num), 'keyed.jpg'), '-djpeg', '-r300');

    end
    
