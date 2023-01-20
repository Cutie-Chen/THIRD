function adaptive_median_filter(Img,Smax)
figure;
imshow(Img);%显示原图
title("椒盐噪声污染的图像");

f=Img;
%image_gray=rgb2gray(f);%得到灰度图像
ff =f;
alreadyProcessed = false(size(f));%生成逻辑非的矩阵
% 迭代
% 从模板n=3开始，以2为间隔
% 对每一个像素，执行相同的步骤
for k = 3:2:Smax
   zmin = ordfilt2(f, 1, ones(k, k), 'symmetric');
   zmax = ordfilt2(f, k * k, ones(k, k), 'symmetric');
   zmed = ordfilt2(f, double(uint8(k*k)/2), ones(k, k),'symmetric');
   
   zA = (zmed > zmin) & (zmax > zmed) &~alreadyProcessed; %真：中值不为噪声，
   zB = (f > zmin) & (zmax > f);%真：该像素不为噪声
   outputZxy  = zA & zB;%满足步骤AB的输出原值对应像素的位置
   outputZmed = zA & ~zB;%满足A不满足B的输出中值对应的像素位置
   ff(outputZxy) = f(outputZxy);
   ff(outputZmed) = zmed(outputZmed);
   
   alreadyProcessed = alreadyProcessed | zA;
   if all(alreadyProcessed(:))
      break;
   end
end
ff(~alreadyProcessed) = zmed(~alreadyProcessed);

figure;
imshow(ff);
title('自适应中值滤波，Smax=7');
end

