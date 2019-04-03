function code = createPrintable16BitCode(num, varargin)
% Generates a printable beeTag image from an integer number
% Second optional argument is a scaling factor (must be an integer) for how
% big to make the output image (default is five)
%
% Example to create a tag for the number "11" scaled up 30 times
%    im = createPrintableCode(11, 30);
%    imshow(im);
%    
code = create16BitCode(num);
code = code';
code = padarray(code,[1 1], 1, 'both');
code = padarray(code, [1 1],'both');
if isempty(varargin)
    sizeFactor = 5;
else
    sizeFactor = varargin{1};
end

code = imresize(code, sizeFactor, 'nearest');

end


