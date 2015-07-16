function [passBin codesFinal orientation codes] = checkOrs(imc)

check = [];
passBin = [];
codes = [];

for cc = 1:4
imcr = rot90(imc,cc);
check(cc) = checkCode25(imcr);
codes(cc,:) = reshape(imcr', 1 ,25);
end

if sum(check)~=1
    passBin = 0;
elseif sum(check) == 1
    passBin=1;
end

codesFinal = codes(find(check==1),:);
orientation = find(check ==1);

end
