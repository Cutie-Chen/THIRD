%% 全局阈值处理
filepath1 = 'Fig1038(a)(noisy_fingerprint).tif';
% 读取图片
Img=imread(filepath1);
% 处理
ImgT = global_thresholding(Img);
% 显示图片
subplot(1,2,1),imshow(Img);title('The original');
subplot(1,2,2),imshow(ImgT);title('After global thresholding');
figure;plot(x,count);axis([0,255,0,25000]);title('Intensity Histogram');
%% 对比全局和Otsu
filepath2 = 'Fig1039(a)(polymersomes).tif';
% 读取图片
Img2=imread(filepath2);
% 分别进行处理全局和Otsu
I1 = global_thresholding(Img2);
I2 = optimum_thresholding(Img2);
% 显示图片
subplot(221);imshow(Img2);title('The original');
subplot(222);imhist(Img2);title('Intensity Histogram');
subplot(223);imshow(I1);title('After Global Thresholding');
subplot(224);imshow(I2);title('After Optimum Thresholding');