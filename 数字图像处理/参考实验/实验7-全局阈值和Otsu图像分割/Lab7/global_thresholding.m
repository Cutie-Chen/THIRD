function ImgT = global_thresholding(Img)

%计算图片的直方图分量count(i)和尺寸
[count,~]=imhist(Img);
[row,col]=size(Img);
%计算图片的灰度平均值T，T将图片的灰度分为类C1和类C2
sum=0;
k=0;
for i=1:256
    sum=sum+count(i)*(i-1);
    k=k+count(i);
end
T=sum/k;
T=round(T);%四舍五入
flag=1;
deltaT = 0;%T值误差
%执行循环直至(T-(T1+T2)/2)小于deltaT，这里取1
times = 0;
while flag==1
    times = times + 1;
    %计算类C1的平均灰度值
    k1=0;
    sum1=0;
    for i=1:T+1
        sum1=sum1+count(i)*(i-1);
        k1=k1+count(i);
    end
    T1=sum1/k1;
    %T1=round(T1);
    
    %计算类C2的平均灰度值
    sum2=0;
    k2=0;
    for i=T+2:256
        sum2=sum2+count(i)*(i-1);
        k2=k2+count(i);
    end
    T2=sum2/k2;
    avgT = round((T1+T2)/2);
    %新的T值在误差范围内，退出循环
    if abs(T-avgT) <= deltaT
        flag=0;
    end
    T=avgT;
end

%将图片进行阈值为T的二分值分割
ImgT=Img;
for i=1:row
    for j=1:col
        if ImgT(i,j)>T
            ImgT(i,j)=255;
        else
            ImgT(i,j)=0;
        end
    end
end

end