function my_Laplacian()
r=imread('building.tif');
Laplacian_mask=[0,1,0;1,-4,1;0,1,0];
result = my_conv(r,Laplacian_mask);
[m,n]=size(r);
for i=1:m
    for j=1:n
    output(i,j)=-result(i,j)+r(i,j);
    end
end
subplot(1,3,1);
imshow(r);
title('原始图像');
subplot(1,3,2);
imshow(result,[0,255]);
title('轮廓图');
subplot(1,3,3);
imshow(output);
title('拉普拉斯校验后图像');


end