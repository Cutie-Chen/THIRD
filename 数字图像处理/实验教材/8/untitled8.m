image1 = imread('0.png');
image2 = imread('1.png');

%读取两张图像并调用sift
[im1, des1, loc1] = sift(image1);
[im2, des2, loc2] = sift(image2);  
des2t = des2; 
for i = 1 : size(des1,1)
   dotprods = des1(i,1) .* des2t(i,1);        
   [vals,indx] = sort(abs(cos(dotprods)),'descend');  %遍历计算特征点关键点描述子向量，计算点乘的cosine值，取最大值对应的两幅图像关键点
   if (vals(1) < 0.5)%认定为近似于0
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

im3 = appendimages(im1,im2);
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);
for i = 1: size(des1,1)
    
  if (match(i) > 0)
    line([loc1(i,2) loc2(match(i),2)+cols1], [loc1(i,1) loc2(match(i),1)], 'Color', 'c');
  end
end
hold off;
for i=1:size(des1,1)
    text(loc1(i,2),loc1(i,1)-5,'.','Color', 'c');
    text(loc2(i,2)+cols1,loc2(i,1)-5,'.','Color', 'c');%为什么这里显示点会偏？？？
end
    

%合并图像
function im = appendimages(image1, image2)
rows1 = size(image1,1);
rows2 = size(image2,1);
if (rows1 < rows2)
     image1(rows2,1) = 0;
else
     image2(rows1,1) = 0;
end
im = [image1 image2];   
end
