function  Gaussian_lowpass_filter(filename,D0,num)
image=imread(filename); %读入图像
[M ,N]=size(image);

img_f = fft2(image);%傅里叶变换得到频谱
img_f=fftshift(img_f);  %频谱中心化

m_mid=round(M/2);%中心点坐标
n_mid=round(N/2);  

h = zeros(M,N);%高斯低通滤波器构造
for i = 1:M
    for j = 1:N
        d = ((i-m_mid)^2+(j-n_mid)^2);%各点到中心点的欧式距离
        h(i,j) = exp(-(d)/(2*(D0^2)));%代入公式      
    end
end

img_lpf = h.*img_f;

img_lpf=ifftshift(img_lpf);    %中心平移回原来状态
img_lpf=uint8(real(ifft2(img_lpf)));  %反傅里叶变换,取实数部分

subplot(3,2,num);
imshow(img_lpf);
title(['D0=',num2str(D0)]);

end
