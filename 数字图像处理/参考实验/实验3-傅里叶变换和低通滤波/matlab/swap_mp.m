function swap_mp(filename1,filename2)
% 计算图像1
img1=imread(filename1);
img1 = imresize(img1,[512,512],'nearest');%图像大小统一为512*512
I1=fft2(im2double(img1)); %傅里叶变换
img1_magnitude=abs(I1);%幅度谱
img1_phase=angle(I1);%相位谱
% 计算图像2
img2=imread(filename2);
img2 = imresize(img2,[512,512],'nearest');%图像大小统一为512*512
I2=fft2(im2double(img2)); 
img2_magnitude=abs(I2); 
img2_phase=angle(I2);
% 交换并重构
restructure1 = ifft2(img1_magnitude.*cos(img2_phase)+img1_magnitude.*sin(img2_phase).*i);
restructure2 = ifft2(img2_magnitude.*cos(img1_phase)+img2_magnitude.*sin(img1_phase).*i);
% 显示图像
subplot(2,2,1),imshow(img1),title('img1');
subplot(2,2,2),imshow(img2),title('img2');
subplot(2,2,3),imshow(restructure1,[]),title('img1_m and img2_p');
subplot(2,2,4),imshow(restructure2,[]),title('img2_m and img1_p');
end