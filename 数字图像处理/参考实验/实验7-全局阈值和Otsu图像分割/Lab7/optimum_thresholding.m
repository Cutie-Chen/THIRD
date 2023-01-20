function I2 = optimum_thresholding(Img)
I =im2double(Img); 
[M,N]=size(I);
pixels_all=M*N; 
gray_all=0;
ICV_t=0;%最大方差

%计算图像平均灰度
for i=1:M
    for j=1:N
        gray_all=gray_all+I(i,j);
    end
end
all_ave=gray_all*255/pixels_all;
 
 
%t为阈值，把图像分为C1（>=t）与C2（<t）
for t=0:255                       %不断试探最优t值
    hui_A=0;                   
    hui_B=0;                     
    C1=0;                  
    C2=0;                   
    for i=1:M                     
        for j=1:N
            if (I(i,j)*255>=t)    
                C1=C1+1;  
                hui_A=hui_A+I(i,j);   
            elseif (I(i,j)*255<t) 
                C2=C2+1; 
                hui_B=hui_B+I(i,j);
            end
        end
    end
    PC1=C1/pixels_all;            
    PC2=C2/pixels_all;            
    C1_ave=hui_A*255/C1;          
    C2_ave=hui_B*255/C2;         
    ICV=PC1*((C1_ave-all_ave)^2)+PC2*((C2_ave-all_ave)^2);  %Otsu算法
    if (ICV>ICV_t)                     %不断判断，得到最大方差
        ICV_t=ICV;
        k=t;                           %得到最大方差的最优阈值
    end
end
k
%将图片进行阈值为k的二分值分割
I2 = uint8(I*255);%还原像素范围为0-255
for i=1:M
    for j=1:N
        if I2(i,j)>=k
            I2(i,j)=255;
        else
            I2(i,j)=0;
        end
    end
end
end