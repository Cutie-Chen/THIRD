function s = stn_ratio(img,img_dec)
[M,N] = size(img);
% 计算分子
sum1 = 0;
for x = 1:M
    for y = 1:N
        sum1 = sum1 + img_dec(x,y).^2;
    end
end
%计算分母
sum2 = 0;
for x = 1:M
    for y = 1:N
        sum2 = sum2 + (img_dec(x,y) - img(x,y)).^2;
    end
end
s = double(sum1)/sum2;
end