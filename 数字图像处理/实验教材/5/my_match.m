function[] = my_match(source_img,target_img)
source_img=imread(source_img);
target_img=imread(target_img);
href=imhist(target_img);
[m1,n1,c]=size(source_img);
% 计算source_img累计直方图
[r1,c1]=size(source_img);
result1=zeros(1,256);            %用作直方图的参数
 %记录所有的灰度值
for i=1:r1
    for j=1:c1
        k=source_img(i,j);
        result1(k+1)=result1(k+1)+1; 
    end
end
%z1为原图的累计直方图
z1=zeros(1,256);
for i=1:256
    for j=1:i
        z1(i)=z1(i)+result1(j);
    end
end
% 累计概率
I_cum_pro_ = cumsum(imhist(source_img))/(m1*n1);
href_cum_pro = cumsum(href/sum(href));
%绘制图像
figure;
    subplot(2, 3, 1), imshow(source_img), title('原图');
    subplot(2, 3, 4),imhist(source_img), title('原图');
% 在原始和目标直方图的等值处，找到原始和目标像素值的映射关系，完成匹配
% 遍历寻找映射灰度值,寻找原图与目标图累计概率最接近的灰度值，存储在match中
match=uint8(zeros(256,1));
for i=1:256
    a = I_cum_pro_(i);
    min = 1;
    index=1;
    for j = 1:256
        b = href_cum_pro(j);
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

    subplot(2, 3, 2), imshow(target_img), title('匹配图');
    subplot(2, 3, 3), imshow(source_img), title('匹配后的新图');
    subplot(2, 3, 5), imhist(target_img), title('匹配图');
    subplot(2, 3, 6), imhist(source_img),title('匹配后的新图');
end









