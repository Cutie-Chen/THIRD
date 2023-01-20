function PseudoColor_Image_Processing(filename,range,outputcolor)
 
I = double(imread(filename));
[M N] = size(I);
I2 = zeros(M, N, 3);                                 %初始化三通道

for x = 1 : M
   for y = 1 : N
      if I(x, y) <= range(2) && I(x, y) >= range(1)
          I2(x,y,1)=outputcolor(1);
          I2(x,y,2)=outputcolor(2);
          I2(x,y,3)=outputcolor(3);
      else
          I2(x,y,1)= I(x, y);
          I2(x,y,2)= I(x, y);
          I2(x,y,3)= I(x, y);
      end
      
   end
end

subplot(1,2,1);imshow(uint8(I));title('原图');
subplot(1,2,2);imshow(uint8(I2));title('映射后');
end