function trans_func_display(Sk)
% 绘制映射函数, 横轴：原图灰度值->映射后灰度值
x=0:1:255;%x轴上的数据，第一个值代表数据开始，第二个值代表间隔，第三个值代表终
scatter(x,Sk(:),5);
axis([0,255,0,255])  %确定x轴与y轴框图大小
set(gca,'XTick',[0:50:255]) %x轴范围1-6，间隔1
set(gca,'YTick',[0:50:255]) %y轴范围0-700，间隔100
xlabel('r')  %x轴坐标描述
ylabel('s') %y轴坐标描述
title('The Histogram-equalization Transformation');
end