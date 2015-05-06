%Functions modified slightly from "CALTag" library (Bradley Atcheson), specifically
%caltag.m. Original calTag code available at
%https://github.com/brada/caltag.

function [isQuad,corners] = fitquad(bbox, mask)
    % default return values
    isQuad = false;
    corners = [];
    % remove small spurs in edge image (holes in mask) that mess things up
    % faster to do it only on potential regions than on the whole image
    mask = padarray( mask, [3,3] );
    mask = imclose( mask, strel('disk',2) );
    mask = mask(4:end-3,4:end-3);
    % trace the perimeter
    seedPoint = find( mask, 1 );
    [sy,sx] = ind2sub( size(mask), seedPoint );  
    perim = bwtraceboundary( mask, [sy,sx], 'NE', 8, Inf, 'clockwise' );
    % using gaussian-smoothed 1st derivative (central differences)
    % precomputed kernel is conv([-1,0,1]/2,fspecial('gaussian',[3,1],1))
    %kernel = [-0.1370;-0.2259;0;0.2259;0.1370];
    % precomputed kernel is conv([-1,0,1]/2,fspecial('gaussian',[5,1],5/3))
    %kernel = [-0.0668;-0.1146;-0.0704;0;0.0704;0.1146;0.0668];
    %bugfix: too small kernel allows small holes and spurs in perimeter to be
    %treated as separate gradient clusters. therefore we need to smooth by a
    %kernel roughly on the order of the size of the smallest quad edge
    kernelSize = floor( min(size(mask))/3 );
    kernel = conv([-1,0,1]/2,fspecial('gaussian',[kernelSize,1],kernelSize/6));
    gradients = imfilter( perim, kernel, 'circular' );
    % this could throw an empytycluster warning if it can't find 4 clusters
    % we disable the warning message in the caller, and check the returned
    % K afterwards to see if it worked
    %[clusteridx,clustermeans] = kmeans( gradients, 4, 'replicates',1 );     % maybe reduce repl for performance reasons?
        
    %debug: the above kmeans clustering works mostly, but is quite slow and can
    % sometimes miss the true clusters because of its random initialisation. 
    % Below we are trying to manually set seed locations to avoid having to do
    % multiple random trial of kmeans. because we know the perimeter
    % istraversed in order, we can choose equispaced gradients as the seeds
    seedIdx1 = floor( linspace( 1, size(gradients,1), 5 ) );
    seedIdx2 = seedIdx1 + floor( diff(seedIdx1(1:2))/2 );
    seeds = cat( 3, gradients(seedIdx1(1:4),:), gradients(seedIdx2(1:4),:) );
    [clusteridx,clustermeans] = kmeans( gradients, 4, 'start',seeds, 'emptyaction','drop' );
    
    nClusters = sum( isfinite( clustermeans(:,1) ) );
    if nClusters ~= 4
        return;
    end    
    % initial assignments of points to lines
    points = { perim(clusteridx==1,:), perim(clusteridx==2,:), ...
               perim(clusteridx==3,:), perim(clusteridx==4,:) };        
    % check to see if any one cluster has too few points
    nPointsPerCluster = cellfun( @length, points );  
    if min(nPointsPerCluster) < max(nPointsPerCluster)/16
        return;
    end          
    % fit a line through the points in each cluster       
    lines  = cellfun( @fitline, points, 'UniformOutput',false );   
    % sometimes little spurs along the edges have the same gradient as
    % other sides of the quad, so they belong to same cluster, but we
    % really don't want to include those points in the linefit. So use
    % Lloyd's Algorithm to fit the lines
    %point2line = @(P,L) abs( dot( repmat(L.n,[size(P,1),1]), ...             % does binding this function cost much time?
    %                              repmat(L.p,[size(P,1),1])-P, 2 ) );        % changed to script function
    maxIter = 6;
    iter = 0;
    isConverged = false; 
    isDegenerate = false;
    %minPtsPrClstr = length( gradients ) / 4 * (0.75);
    minPtsPrClstr = length( gradients ) / 16 * (0.75);
    while ~isDegenerate() && iter<maxIter && ~isConverged 
        % uncomment to check the quad fitting function...
        %debugPlotQuadFit( mask, points, lines );
        distances = cellfun( @point2line, {perim,perim,perim,perim}, ...
                             lines, 'UniformOutput',false );
        [mindist,minidx] = min( cell2mat(distances), [], 2 );
        newPoints = { perim(minidx==1,:), perim(minidx==2,:), ...
                      perim(minidx==3,:), perim(minidx==4,:) };      
        iter = iter + 1;
        isConverged = isequal( points, newPoints ); 
        %isDegenerate = any( cellfun(@numel,newPoints) < 2*minPtsPrClstr );
        isDegenerate = any( cellfun(@numel,newPoints) < minPtsPrClstr );
        if ~isConverged   
            points = newPoints;
            lines  = cellfun( @fitline, points, 'UniformOutput',false );      
        end
    end
    if ~isConverged
        return;
    end   
    % figure out which line is parallel to the first
    dotprods = [0,0,0,0];
    for i = 2:4
        dotprods(i) = abs( dot( lines{1}.d, lines{i}.d ) );
    end
    [dotprods,idx] = sort( dotprods );
    %if dotprods(4) < 0.75 || any( dotprods(2:3)>0.5 )
    %    return;
    %end
    if dotprods(4) < 0.75 || abs(diff(dotprods(2:3)))>0.2
        return;
    end
    lines = lines(idx);        
    % get the line intersection points
    corners = [ intersectLines( lines{1}, lines{2} ),...
                intersectLines( lines{2}, lines{4} ),...
                intersectLines( lines{4}, lines{3} ),...
                intersectLines( lines{3}, lines{1} ) ];   
    % check if any corners points lie well outside the boundingbox    
    midToCorner = corners - repmat( size(mask)'/2, [1,4] );
    [theta,rho] = cart2pol( midToCorner(1,:), midToCorner(2,:) );
    if any( rho > 1.1*sqrt(sum(size(mask).^2))/2 )
        return;
    end    
    % sort the corners into counterclockwise order
    [theta,idx] = sort( theta );
    %rho = rho(idx); % don't need rho again
    corners = corners(:,idx);
    % if using the rotated layout (2) then we need to transform these
    % corners so that they lie at the bowtie centres
    
    % convert corners into global image coordinates
    corners = corners + repmat( bbox([2,1])', [1,4] );
    isQuad = true;
    
    function line = fitline( points )
    points = points(~isnan(points(:,1)),:);
    if size( points, 2 ) < 2
        line = [];
        return;
    end
    point = mean( points );
    covmatrix = cov( points );
    [evecs,evals] = eig( covmatrix );
    [maxeval,maxidx] = max( diag(evals) );
    dir = evecs(:,maxidx);
    normal = [0,1;-1,0] * dir;
    line = struct( 'p',point, 'd',dir', 'n',normal' );
    
    % orthogonal distances from Nx2 array of points to a line
function y = point2line( P, L ) 
    y = abs( dot( repmat(L.n,[size(P,1),1]), ...
                  repmat(L.p,[size(P,1),1])-P, 2 ) );
  
              
              % return the 2D intersection point (column vec) of two lines
% assuming they are not colinear
% column vec: [vertical coord; horizontal coord]
function p = intersectLines( line1, line2 )
    alpha = [line1.d',line2.d'] \ (line2.p'-line1.p');
    p = line1.p' + alpha(1) * line1.d';
    
    % plot debug into to see if lloyds algorithm is converging
% region is the binary image corresponding to 'FilledImage'
% lines and points are 4-element cell arrays
function debugPlotQuadFit( region, points, lines )
    nLines = length( lines );
    assert( nLines == length(points) );
    colours = 'rgbycmk';
    region = bwperim( region );
    imshow( region * 0.2 );
    hold on;
    dbgPlotPoints = @(p,c) plot( p(:,2), p(:,1), strcat(c,'O') );
    k = max( size(region) );
    dbgPlotLine = @(l,c) line( [ l.p(2)-k*l.d(2), l.p(2)+k*l.d(2) ], ...
                               [ l.p(1)-k*l.d(1), l.p(1)+k*l.d(1) ], ...
                               'Color',c );
    for i = 1:nLines
        dbgPlotPoints( points{i}, colours(i) );
        dbgPlotLine( lines{i}, colours(i) );
    end
    hold off;