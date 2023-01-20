function log_trans(filename)
% 读取图像
img_1 = imread(filename);

% 显示图像
subplot(2,3,1), 
imshow(img_1);
title('The Original Image');

c=0.6;
img_2 = c * mat2gray(log(1 + double(img_1))); 
subplot(2,3,2), 
imshow(img_2);
title(['c=',num2str(c)]);

c=0.8;
img_2 = c * mat2gray(log(1 + double(img_1))); 
subplot(2,3,3), 
imshow(img_2);
title(['c=',num2str(c)]);

c=1;
img_2 = c * mat2gray(log(1 + double(img_1))); 
subplot(2,3,4), 
imshow(img_2);
title(['c=',num2str(c)]);

c=1.2;
img_2 = c * mat2gray(log(1 + double(img_1))); 
subplot(2,3,5), 
imshow(img_2);
title(['c=',num2str(c)]);

c=1.6;
img_2 = c * mat2gray(log(1 + double(img_1))); 
subplot(2,3,6), 
imshow(img_2);
title(['c=',num2str(c)]);

end