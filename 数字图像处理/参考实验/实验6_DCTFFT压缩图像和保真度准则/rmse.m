function r = rmse(img,img_dec)
[M,N] = size(img);
sum = 0;
for x = 1:M
    for y = 1:N
        sum = sum + (img_dec(x,y) - img(x,y)).^2;
    end
end
r = double(sum)/(M*N);
end