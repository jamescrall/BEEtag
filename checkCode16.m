function [pass] = checkCode16(imc)
    
im = imc(1:3,:);
check = imc(4,:);
tmp = [];

for bb = 1:3
    if mod(sum(im(bb,:)), 2)==check(bb)
        tmp(bb) = 0;
    else
        tmp(bb) = 1;
    end
end


    if mod(sum(sum(im)),2) == check(4)
        tmp(4) = 0;
    else
        tmp(4) = 1;
    end
    
    
    if(sum(tmp)) > 0
        pass = 0;
    else
        pass = 1;
    end


end