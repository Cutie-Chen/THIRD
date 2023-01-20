function [] = my_rotation(file_name,rotation_degree)                                 %定义旋转函数，degree为要旋转的角度
   
    I=imread(file_name);
    I1=imrotate(I,rotation_degree);     %调用imrotate()函数旋转指定角度
    imwrite(I1,'rotated_image.tif');
    imshow('rotated_image.tif')
end



