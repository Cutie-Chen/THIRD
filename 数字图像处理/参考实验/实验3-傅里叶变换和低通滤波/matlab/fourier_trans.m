function fourier_trans(filename)
% 显示图像幅度谱
I=imread(filename); %读入图像
F=fft2(I); %FFT
F=fftshift(F); %FFT频谱平移
T=log(F+1); %频谱对数变换
T=real(T);%取实数部分
subplot(1,2,1),imshow(I),title('The original image');
subplot(1,2,2),imshow(T,[]),title('The specturm');
end

