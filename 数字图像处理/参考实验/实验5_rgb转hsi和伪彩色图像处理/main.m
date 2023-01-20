filename1 = 'rgb.jpg';
filename2 = 'Fig0110(4)(WashingtonDC Band4).TIF';
%% RGB TO HSI
rgb2hsi(filename1);

%% Pseudo-Color Image Processing-指定rgb
% 用户输入范围
range = input('输入灰度范围(如[0,30]):');
% 指定该范围输出颜色
outputcolor = input('该灰度范围的映射rgb为(如[255,255,0]):');
%outputcolor = [r,g,b];
% 为河流上色
PseudoColor_Image_Processing(filename2,range,outputcolor);

%% Pseudo-Color Image Processing-枚举rgb
% 用户输入范围
range = input('输入灰度范围(如[0,30]):');
% 指定该范围输出颜色
colorname = input('该灰度范围的映射rgb为(red,green,blue,cyan,magenta,yellow,white):','s');
%outputcolor = [r,g,b];
% 为河流上色
PseudoColor_Image_Processing2(filename2,range,colorname);
