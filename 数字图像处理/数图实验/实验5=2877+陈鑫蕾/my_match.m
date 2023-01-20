function[] = my_match(source_img,target_img)
%读取图像
source_img=imread(source_img);
target_img=imread(target_img);
href=imhist(target_img);
[m1,n1,c]=size(source_img);
% 累计概率
source_cum = cumsum(imhist(source_img))/(m1*n1);
target_cum= cumsum(href/sum(href));
%绘制图像
figure;
    subplot(2, 3, 1), imshow(source_img), title('原图');
    subplot(2, 3, 4), imhist(source_img), title('原图');
% 在原始和目标直方图的等值处，找到原始和目标像素值的映射关系，完成匹配
% 遍历寻找映射灰度值,寻找原图与目标图累计概率最接近的灰度值，存储在match中
match=uint8(zeros(256,1));
for i=1:256
    a = source_cum(i);
    min = 1;
    index=1;
    for j = 1:256
        b = target_cum(j);
       if abs(a-b) < min  
           min=abs(a-b);
           index = j;
       end
    end
    match(i)=index - 1;  %灰度级=直方图统计下标 - 1 
end
% 遍历原图像，更新规定化的灰度值
for i=1:m1
    for j=1:n1
        t=source_img(i,j);
        source_img(i,j) = match(t+1);
    end
end
%绘制图像
    subplot(2, 3, 2), imshow(target_img), title('匹配图');
    subplot(2, 3, 3), imshow(source_img), title('匹配后的新图');
    subplot(2, 3, 5), imhist(target_img), title('匹配图');
    subplot(2, 3, 6), imhist(source_img), title('匹配后的新图');
end









