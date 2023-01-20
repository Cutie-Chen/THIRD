function median_filter(Img,n)
%n=7;    %模板大小
Img = after_sp;
[height, width]=size(Img);   %获取图像的尺寸（n小于图片的宽高）
subplot(1,3,1);
imshow(Img);%显示原图
title("原图");
x1=double(Img);  %数据类型转换
x2=x1;  %转换后的数据赋给x2
%对图像边缘进行填充,补0
%左边
for i=1:(n-1)/2
    x2(:,i)=0;
end
%右边
for i=width-(n-1)/2+1:width
    x2(:,i)=0;
end
%上面
for i=1:(n-1)/2
    x2(i,:)=0;
end
%下面
for i=height-(n-1)/2+1:height
    x2(i,:)=0;
    
end

for i=1:height-n+1  
    for j=1:width-n+1  
        c=x1(i:i+(n-1),j:j+(n-1)); %在x1中从头取模板大小的块赋给c  
        e=c(1,:);      %e中存放是c矩阵的第一行  
        for u=2:n  %将c中的其他行元素取出来接在e后使e为一个行矩阵 
            e=[e,c(u,:)];          
        end  
        med=median(e);      %取一行的中值  
        x2(i+(n-1)/2,j+(n-1)/2)=med;   %将模板各元素的中值赋给模板中心位置的元素  
    end  
end    
d=uint8(x2);  %未被赋值的元素取原值 
subplot(1,3,2);
imshow(d);  %显示过滤图片
title("自定义7x7中值滤波");
%x0=rgb2gray(Img);  %灰度处理，灰度处理后的图像是二维矩阵
b=medfilt2(Img,[n,n]);  %matlab中自带值滤波函数
subplot(1,3,3);
imshow(b); %显示过滤后的灰度图片
title("matlab自带中值滤波");
end