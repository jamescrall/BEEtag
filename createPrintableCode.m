function code = createPrintableCode(num)
%% Generates a printable idBEE tag image from an integer number

code = createCode(num);

code = padarray(code,[1 1], 1, 'both');
code = padarray(code, [1 1],'both');
end


