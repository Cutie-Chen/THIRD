function []= my_eq (source_img)
R = imread(source_img);
[height,width]=size(R);

% 统计像素灰度值
pixelnum = zeros(1,256);
for i = 1:height
    for j = 1:width
        pixelnum(R(i,j)+1) = pixelnum(R(i,j)+1)+1;
    end
end

% 计算灰度分布密度
normalizedpixel = zeros(1,256);
for i = 1:256
    normalizedpixel(i) = pixelnum(i) / (height * width * 1.0);
end

%通过变换函数的离散形式来均衡化处理
sk=zeros(1,256);
s1=zeros(1,256);
temp=0;
for i=1:256
    temp=temp+normalizedpixel(i);
    sk(i)=temp;
end
s1=round(sk*255);%乘上255,再向下取整

newhis=zeros(1,256);
for i=1:256
    newhis(i)=sum(normalizedpixel(find(s1==(i-1))));
end

%变化后的图像
S=R;
for i=1:256
    S(find(R==(i-1)))=s1(i);
end

%绘制图像
figure(1)
% uint8函数：把参数转换为无符号数
subplot(121),imshow(uint8(R)),title('原始图像');
subplot(122),imshow(uint8(S)),title('直方图均衡后的图像');
figure(2)
% imhist函数：显示图像的灰度直方图
subplot(121),imhist(R,64),title('原始直方图');
subplot(122),imhist(S,64),title('处理后的直方图');
end

