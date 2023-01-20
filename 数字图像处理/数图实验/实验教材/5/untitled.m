function[]
% 1.添加运动模糊

img = imread('cover.tif'); % 读取图像
figure(1);
subplot(221);
imshow(img);
title("原始图像");

[M,N,Z]=size(img);
H = zeros(M,N);
T=1;a=0.1;b=0.1;
for i = 1:M
   for j = 1:N
       x=i-M/2+0.01;
       y=j-N/2+0.01;
       H(i,j) = (T/(pi*(x*a+y*b))) * sin(pi*(x*a+y*b))*exp(-1j*pi*(x*a+y*b));
    end
end
F=fftshift(fft2(im2double(img)));
G=F.*H;
Blurred2=ifft2(ifftshift(G));
subplot(222);
imshow(Blurred2);
title("运动模糊图像");

% 2.添加噪声
NUM2 = 0.05; % 噪声强度5%
I1 = imnoise(img, 'gaussian', NUM2); % 给原始图像添加高斯噪声，强度5%
subplot(223);
imshow(I1);
title('添加高斯噪声的图像');
 
NUM2 = 0.05; % 噪声强度5%
I2 = imnoise(Blurred2, 'gaussian', NUM2); % 给模糊图像添加高斯噪声，强度5%
subplot(224);
imshow(I2);
title('模糊且加噪的图像');



 
 