%% 加高斯噪声
filename = 'Fig0507(a)(ckt-board-orig).tif';
mean = 0;
var = 0.01;
after_gussian=gussian_noise(filename,mean,var);

%% 加椒盐噪声
filename = 'Fig0507(a)(ckt-board-orig).tif';
d1 = 0.5;%控制噪声密度
d2 = 0.5;%控制黑点和白点的比例
after_sp=sp_noise(filename,d1,d2);

%% 7x7中值滤波
n=7; %模板大小
median_filter(after_sp,n)

%% 7x7自适应中值滤波
n=7; %模板大小
Smax=7;
adaptive_median_filter(after_sp,Smax)
