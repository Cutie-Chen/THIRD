clear
%读入图像
img1 = imread('0.png');
img2 = imread('1.png');
%sift
[image1,des1,loc1] =sift(img1);
[image2,des2,loc2] = sift(img2);
%绘制特征点
figure;
imshow(image1);
hold on;
plot(loc1(:,2),loc1(:,1),'+g');
title('原图')
figure;
imshow(image2);
hold on;
plot(loc2(:,2),loc2(:,1),'+g');
title('待识别图像')
%匹配,将image1的每个特征点的128维向量与image2所有向量做一个内积
des2t = des2';
n = size(des1,1);
matched = zeros(1,n);
for i = 1 : n
   dotprods = des1(i,:) * des2t;
   [values,index] = sort(acos(dotprods));%反cos值并且升序排序
   if (values(1) < 0.00001)%差值近似与0
      matched(i) = index(1);
   else
      matched(i) = 0;
   end
end
%合并两张图片并绘制连接线
rows1 = size(image1,1);
rows2 = size(image2,1);
if (rows1 < rows2)
     image1(rows2,1) = 0;
else
     image2(rows1,1) = 0;
end
img3 = [image1 image2];
figure('Position', [100 100 size(img3,2) size(img3,1)]);
colormap gray;
imagesc(img3);
title("带特征点的原图/带特征点的目标图像");
hold on;
cols1 = size(image1,2);
%防止数组越界
n1 = size(loc1,1);
n2 = size(loc2,1);
n = min(n1,n2);
%设置线的不同颜色
colors = ['c','m','y'];
colors_n = length(colors);
%进行连线
for i = 1: n
    color = colors(randi(colors_n));
    line([loc1(i,2) loc2(i,2)+cols1], ...
         [loc1(i,1) loc2(i,1)], 'Color', color);
end
