function histogram_trans(filename)
% 读取原图
R = imread(filename);
[row, col] = size(R);

% 显示原图和原图对应的直方图
subplot(2,2,1), imshow(R), title('原灰度图');
subplot(2,2,2), imhist(R), title('原灰度图的直方图');

% 计算PMF，并归一化
PMF = zeros(1, 256); 
for i = 1:row
    for j = 1:col
        PMF(R(i,j) + 1) = PMF(R(i,j) + 1) + 1; % R(i,j)为像素的灰度值
    end
end
PMF = PMF / (row * col);

% 计算CDF
CDF = zeros(1,256);
CDF(1) = PMF(1);
for i = 2:256
    CDF(i) = CDF(i - 1) + PMF(i);
end

% 四舍五入，计算均衡后的像素值
Sk = zeros(1,256);
for i = 1:256
    Sk(i) = CDF(i) * 255;
end
Sk = round(Sk);

% 输出映射函数图像
%trans_func_display(Sk);

% 映射到新的像素值
for i = 1:row
    for j = 1:col
        R(i,j) = Sk(R(i,j) + 1);
    end
end

% 绘制直方图均衡后的图像
subplot(2,2,3), imshow(R), title('直方图均衡');
subplot(2,2,4), imhist(R), title('均衡后的直方图');

end