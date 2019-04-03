function imc = create16BitCode(num)

%%
%Create plot of matrix from binary data

%length of tag code
nBit = 12;

%ID number

%Convert ID number to binary
bin = dec2bin(num);

%Take length of binary code
L = numel(bin);
im = zeros(1, nBit);

for i = 1:L
    
im(nBit-L+i) = str2num(bin(i));

end

im = reshape(im,4,3)';

%checksum
check = [];




for aa = 1:3   
    
    check(aa)  = mod(sum(im(aa,:)), 2);
       
end
    
check(4) =  mod(sum(sum(im)), 2);

imc = [im; check];
end