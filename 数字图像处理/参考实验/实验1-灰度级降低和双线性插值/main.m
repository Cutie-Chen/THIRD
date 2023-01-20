%% 降低灰度级主程序
imgpath = pwd + "\Fig0221(a)(ctskull-256).tif" ;
k= input(" Please input the desired k ：");
reduce_factor = 9 - k;
reduce_gray_levels(imgpath,reduce_factor);

%% 双线性插值主程序
% step1: shrink image
imgpath = 'Fig0219(rose1024).tif';
sizex= input(" Please input the desired size x ：");
sizey= input(" Please input the desired size y ：");
output_filename = bilinear_interpolation(imgpath, sizex, sizey);

% step2: zoom image
bilinear_interpolation(output_filename, 1024, 1024);