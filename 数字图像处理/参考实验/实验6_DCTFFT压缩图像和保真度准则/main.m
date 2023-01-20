mask1=[1 1 1 1 1 1 1 1
       1 1 1 1 1 1 1 0
       1 1 1 1 1 1 0 0
       1 1 1 1 1 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0]; %32
mask2=[1 1 1 1 1 1 0 0
       1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];%16
mask3=[1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];%8

Img = imread('Fig0809(a).tif'); %输入灰度图像
Img = im2double(Img);
%% DCT
D = dctmtx(8); % 8*8大小的DCT变换矩阵
fun = @(block_struct)D*(block_struct.data)*D';
Img_dct = blockproc(Img,[8,8],fun);  %D'为D的转置

fun2 = @(block_struct)mask1.*(block_struct.data);
X1 = blockproc(Img_dct,[8,8],fun2);  %保留32个系数
fun3 = @(block_struct)D'*(block_struct.data)*D;
I1  = blockproc(X1,[8,8],fun3);    %重构图像
% 计算均方根误差
r1 = rmse(Img,I1)
% 计算均方信噪比
s1 = stn_ratio(Img,I1)

fun4 = @(block_struct)mask2.*(block_struct.data);
X2 = blockproc(Img_dct,[8,8],fun4);  %保留16个系数
I2  = blockproc(X2,[8,8],fun3);    %重构图像
% 计算均方根误差
r2 = rmse(Img,I2)
% 计算均方信噪比
s2 = stn_ratio(Img,I2)

fun5 = @(block_struct)mask3.*(block_struct.data);
X3 = blockproc(Img_dct,[8,8],fun5);   %保留8个系数
I3  = blockproc(X3,[8,8],fun3);    %重构图像
% 计算均方根误差
r3 = rmse(Img,I3)
% 计算均方信噪比
s3 = stn_ratio(Img,I3)

subplot(2,2,1);imshow(Img);title('原图');
subplot(2,2,2);imshow(I1);title('保留32个系数');
subplot(2,2,3);imshow(I2);title('保留16个系数');
subplot(2,2,4);imshow(I3);title('保留8个系数');


%% FFT
%D = dctmtx(8); % 8*8大小的DCT变换矩阵
%fun = @(block_struct)D*(block_struct.data)*D';
fun = @(block_struct)fft2(block_struct.data);
Img_dct = blockproc(Img,[8,8],fun);  %D'为D的转置

fun2 = @(block_struct)mask1.*(block_struct.data);
X1 = blockproc(Img_dct,[8,8],fun2);  %保留32个系数
fun3 = @(block_struct)real(ifft2(block_struct.data));
I1  = blockproc(X1,[8,8],fun3);    %重构图像
% 计算均方根误差
r1 = rmse(Img,I1)
% 计算均方信噪比
s1 = stn_ratio(Img,I1)

fun4 = @(block_struct)mask2.*(block_struct.data);
X2 = blockproc(Img_dct,[8,8],fun4);  %保留16个系数
I2  = blockproc(X2,[8,8],fun3);    %重构图像
% 计算均方根误差
r2 = rmse(Img,I2)
% 计算均方信噪比
s2 = stn_ratio(Img,I2)

fun5 = @(block_struct)mask3.*(block_struct.data);
X3 = blockproc(Img_dct,[8,8],fun5);   %保留8个系数
I3  = blockproc(X3,[8,8],fun3);    %重构图像
% 计算均方根误差
r3 = rmse(Img,I3)
% 计算均方信噪比
s3 = stn_ratio(Img,I3)

subplot(2,2,1);imshow(Img);title('原图');
subplot(2,2,2);imshow(I1);title('保留32个系数');
subplot(2,2,3);imshow(I2);title('保留16个系数');
subplot(2,2,4);imshow(I3);title('保留8个系数');