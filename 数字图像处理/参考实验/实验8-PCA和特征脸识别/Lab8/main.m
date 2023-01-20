%% 绘制函数图
d = 10:10:100;
y = [];
for i = 1:10
    rate = pca_eigenface(d(i));
    y =[y rate];
end
plot(d,y);