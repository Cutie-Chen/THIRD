imgpath = 'Fig0441(a)(characters_test_pattern).tif';
%% 图像频谱图
fourier_trans(filename);
%% 高斯低通滤波
subplot(3,2,1);
imshow(imread(filename));
title('The original image');
D0=5;  %截止频率
Gaussian_lowpass_filter(filename,D0,2);
D0=15;  %截止频率
Gaussian_lowpass_filter(filename,D0,3);
D0=30;  %截止频率
Gaussian_lowpass_filter(filename,D0,4);
D0=80;  %截止频率
Gaussian_lowpass_filter(filename,D0,5);
D0=230;  %截止频率
Gaussian_lowpass_filter(filename,D0,6);
%% 分别显示两图像的幅度谱和相位谱
filename1='Fig0424(a)(rectangle).tif';
show_mp(filename1);
filename2='Fig0427(a)(woman).tif';%人
show_mp(filename2);
%% 交换两图幅度谱和相位谱并重构
swap_mp(filename1,filename2);