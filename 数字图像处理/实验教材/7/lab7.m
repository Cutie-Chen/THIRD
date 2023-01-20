clear;
clc;

img=imread('Fig0651.png'); 
markwater=imread('xmu.png'); 
figure(1);   
subplot(2,2,1);
imshow(img);
title('载体图像');
subplot(2,2,2);   
imshow(markwater);
title('水印图像'); 

%将原图由RGB模式变成YUV模式
yuv=rgb2ycbcr(img);
Y=yuv(:,:,1);    %灰度层
U=yuv(:,:,2);    %色彩层
V=yuv(:,:,3);    %亮度层

%将水印图片转成二值图
mark_gray=rgb2gray(markwater);
markwater=im2bw(mark_gray);    
msize=size(markwater);  

%水印嵌在色彩层上
alpha=30;    
k1=randn(1,8);  
k2=randn(1,8);
[rm2,cm2]=size(U);

%将载体图像的灰度层分为8×8的小块，每一块内做二维DCT变换
bdct=blkproc(U,[8 8],'dct2');  
adct=bdct; 
for i=1:msize(1)        
    for j=1:msize(2)
        x=(i-1)*8;
        y=(j-1)*8;
        if markwater(i,j)==1
            j=k1;
        else
            j=k2;
        end
        adct(x+1,y+8)=bdct(x+1,y+8)+alpha*j(1);
        adct(x+2,y+7)=bdct(x+2,y+7)+alpha*j(2);
        adct(x+3,y+6)=bdct(x+3,y+6)+alpha*j(3);
        adct(x+4,y+5)=bdct(x+4,y+5)+alpha*j(4);
        adct(x+5,y+4)=bdct(x+5,y+4)+alpha*j(5);
        adct(x+6,y+3)=bdct(x+6,y+3)+alpha*j(6);
        adct(x+7,y+2)=bdct(x+7,y+2)+alpha*j(7);
        adct(x+8,y+1)=bdct(x+8,y+1)+alpha*j(8);
        
    end
end

%将经处理的图像分为8×8的小块，每一块内做二维DCT逆变换
result=blkproc(adct,[8 8],'idct2');
ayuv=cat(3,Y,result,V);      
rgb=ycbcr2rgb(ayuv);   
imwrite(rgb,'mark.png','png');
subplot(2,2,3);
imshow(rgb,[]);
title('添加水印后的图像');    

withmark=rgb;
U_mark=withmark(:,:,2);%取出withmark图像的灰度层

%提取水印
bidct=blkproc(U_mark,[8,8],'dct2');   
aidct=zeros(1,8);      

%将之前改变过数值的点的数值提取出来
for i=1:msize(1)
    for j=1:msize(2)
        x=(i-1)*8;y=(j-1)*8;
        aidct(1)=bidct(x+1,y+8);         
        aidct(2)=bidct(x+2,y+7);
        aidct(3)=bidct(x+3,y+6);
        aidct(4)=bidct(x+4,y+5);
        aidct(5)=bidct(x+5,y+4);
        aidct(6)=bidct(x+6,y+3);
        aidct(7)=bidct(x+7,y+2);
        aidct(8)=bidct(x+8,y+1);
        if corr2(aidct,k1)>corr2(aidct,k2)%corr2计算两个矩阵的相似度，越接近1相似度越大
        markwater(i,j)=0;%比较提取出来的数值与随机频率k1和k2的相似度，还原水印图样
        else
        markwater(i,j)=1;
        end
    end
end

subplot(2,2,4);
imshow(markwater,[]);
title('提取出的水印');

