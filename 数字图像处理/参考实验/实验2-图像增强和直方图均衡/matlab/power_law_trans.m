function power_law_trans(filename)
% 读取图像
img_1 = imread(filename);
subplot(2,2,1);
imshow(img_1);
title('原始图像');

c = 1;
r = 0.3;%gamma值
img_2 = c * (mat2gray(double(img_1).^r));
subplot(2,2,2);
imshow(img_2);
title(['c=',num2str(c),', r=',num2str(r)]);

r = 0.4;
img_2 = c * (mat2gray(double(img_1).^r));
subplot(2,2,3);
imshow(img_2);
title(['c=',num2str(c),', r=',num2str(r)]);

r = 0.6;
img_2 = c * (mat2gray(double(img_1).^r));
subplot(2,2,4);
imshow(img_2);
title(['c=',num2str(c),', r=',num2str(r)]);

end

