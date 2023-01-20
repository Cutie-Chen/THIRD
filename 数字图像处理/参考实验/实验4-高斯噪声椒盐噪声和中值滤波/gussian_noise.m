function [OutputImg]=gussian_noise(filename,mean,var)
%Img=imread('Fig0507(a)(ckt-board-orig).tif');
Img=imread(filename);
figure,imshow(Img),title('原图');
t1=imnoise(Img,'gaussian',mean,var);
figure,
imshow(t1),title(['添加均值=',num2str(mean),',方差=',num2str(var),'的高斯噪声']);
OutputImg = t1;
end
