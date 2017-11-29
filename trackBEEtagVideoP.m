function trackingData = trackBEEtagVideoP(vid, brFilt, brThresh, taglist)
    % trackBEEtagVideoP - function for tracking BEEtags in each frame of a
    % video
    %
    %   Inputs
    %
    %       vid: matlab VideoReader object
    %
    %       brFilt: size threshold size (in pixels) values for local intensity smoothing. At typical resolution, values of 10-30 are usually a good starting point
    %
    %       brThresh: bradley threshold values (range of 0.5-5 good starting point)
    %
    %       taglist: an n x m matrix, where n is the number of unique tags to
    %       be tracked in the video, and the first column contains the list of
    %       tag numbers to be tracked
    %
    %
    %   Outputs
    %       trackingData: m x n x 4 matrix, where m is the number of frames in
    %       the video, n is the number of tags from taglist (above). The 4
    %       sheets of the matrix are the x and y coordinates of the tag
    %       centroid and the x and y coordinates of the tag's front edge, respectively.
    
    
    %%        Set up dummy variables
    nframes = vid.NumberOfFrames;
    
    tags = taglist(:,1);
    xcent = nan(nframes, numel(tags));
    ycent = nan(nframes, numel(tags));
    frontx = nan(nframes, numel(tags));
    fronty = nan(nframes, numel(tags));
    ntags = numel(tags);
    
    if numel(brFilt) == 1
        brFilt = [brFilt brFilt]
    end
    
    hbar = parfor_progressbar(nframes,'Tracking tags for nest video...')
    tic
    %% Track across frames
    
    parfor i = 1:nframes
        %%
        
%       try    % Optional try/catch loop. To implement this to catch rare
%               %errors, uncomment this and lines below to ignore rare errors
            im = rgb2gray(read(vid,i));
            
            F = locateCodes(im,'threshMode', 1,'sizeThresh', [200 1500], 'bradleyFilterSize', brFilt, 'bradleyThreshold', brThresh, 'vis', 0);
            if ~isempty(F)
                rtags = [F.number];
                for j = 1:ntags
                    
                    rt = F(rtags == tags(j));
                    
                    if numel(rt) == 1
                        xcent(i,j) = rt.Centroid(1);
                        ycent(i,j) = rt.Centroid(2);
                        frontx(i,j) = rt.frontX;
                        fronty(i,j) = rt.frontY;
                    end
                end
            end
            
%          % See note above
%         catch
%             disp(strcat('Error in frame ', num2str(i), ', skipping...'));
%         end

        
        hbar.iterate(1);
    end
    
    toc
    
    %% Reshape data into single output matrix
    trackingData = nan(nframes, ntags, 4);
    trackingData(:,:,1) = xcent;
    trackingData(:,:,2) = ycent;
    trackingData(:,:,3) = frontx;
    trackingData(:,:,4) = fronty;
    
    close(hbar);