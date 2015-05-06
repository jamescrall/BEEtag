function [pass] = checkCode25(imc)
    
im = imc(1:3,:);
check = imc(4,:);
check2 = imc(5,:);
tmp = [];

for bb = 1:3
    if mod(sum(im(bb,:)), 2)==check(bb)
        tmp(bb) = 0;
    else
        tmp(bb) = 1;
    end
end

    if mod(sum(sum(im(:,1:3))),2) == check(4)
        tmp(4) = 0;
    else
        tmp(4) = 1;
    end
    
    if mod(sum(sum(im(:,4:5))),2) == check(5)
        tmp(5) = 0;
    else
        tmp(5) = 1;
    end
    
    
cor = sum(check == fliplr(check2));
 if  cor==5
     tmp(6) = 0;
 else tmp(6) = 1;
 end
    
if(sum(tmp)) > 0
    pass = 0;
else pass = 1;
    
end



end