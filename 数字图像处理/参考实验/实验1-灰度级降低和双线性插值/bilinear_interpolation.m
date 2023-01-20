function[output_filename] = bilinear_interpolation( imgpath, sizex, sizey)
%% 1. 读入图像,并根据用户输入的size创建新图像。
InputImg = imread(imgpath);
[height,width,rgb] = size(InputImg);
new_width = round(sizex); 
new_height = round(sizey); 
OutputImg = zeros(new_width,new_height,rgb); 
%% 2. 拓展原图像边缘
InputTemp = zeros(height+2,width+2,rgb);
InputTemp(2:height+1,2:width+1,:) = InputImg;

% 处理原图四条边（除四个顶点外）
InputTemp(1,2:width+1,:)=InputImg(1,:,:);
InputTemp(height+2,2:width+1,:)=InputImg(height,:,:);
InputTemp(2:height+1,1,:)=InputImg(:,1,:);
InputTemp(2:height+1,width+2,:)=InputImg(:,width,:);

% 处理原图四个顶点
InputTemp(1,1,:) = InputImg(1,1,:);
InputTemp(1,width+2,:) = InputImg(1,width,:);
InputTemp(height+2,1,:) = InputImg(height,1,:);
InputTemp(height+2,width+2,:) = InputImg(height,width,:);

%% 3. 由新图像的某个像素（i,j）映射到原始图像(ii，jj)处，并插值计算。
% 步长
step = (width-1)/(new_width-1);

% 扫描新图像的每个像素
for j = 1:new_height 
    for i = 1:new_width  
        % (i,j)对应原图中的虚拟位置[从(0, 0)开始的表示法]
        ii = step*(i-1); 
        jj = step*(j-1);
        % 向下取整（决定距离最近的四个像素点位置）
        u = floor(ii); 
        v = floor(jj); 
        % 小数部分（决定权值）
        a = ii - u;
        b = jj - v;
        % 图像中最小坐标值设为(1, 1)
        u = u + 1; 
        v = v + 1;
        % 双线性插值计算公式
        OutputImg(i,j,:) = (1-a)*(1-b)*InputTemp(u,v,:) +(1-a)*b*InputTemp(u,v+1,:) + a*(1-b)*InputTemp(u+1,v,:) +a*b*InputTemp(u+1,v+1,:);
    end
end

%% 4. 输出结果
% 输出图像
OutputImg = uint8(OutputImg);
output_filename = ['rose-output/Rose_OutputImg(',num2str(new_width),'x',num2str(new_height),').tif'];
imwrite(OutputImg,output_filename);
% 对比展示
subplot(1,2,1);
imshow(InputImg);
title(['原图像（大小： ',num2str(height),'*',num2str(width),')']);
subplot(1,2,2);
imshow(OutputImg);
title(['插值后的图像（大小： ',num2str(new_width),'*',num2str(new_height),')']);

end  