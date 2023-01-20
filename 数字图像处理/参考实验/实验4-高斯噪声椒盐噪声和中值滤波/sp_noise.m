%d1:总噪声密度
%d2:黑白点比例
function [OutputImg]=sp_noise(filename,d1,d2)
Img=imread(filename);
Img2 = Img;
[m,n] = size(Img); %获取图像大小，行数m，列数n
imshow(Img),title('原图');,
flag1 = rand(m,n)<d1;
flag2 = rand(m,n)<d2;
Img2(flag1&flag2)=0;
Img2(flag1& ~flag2)=255;
figure,imshow(Img2),title(['加入pepper&salt,d1=',num2str(d1),',d2=',num2str(d2)]);
OutputImg=Img2;
end

