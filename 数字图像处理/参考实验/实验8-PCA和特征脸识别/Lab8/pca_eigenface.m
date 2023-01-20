function rate = pca_eigenface(d)
%% 对半分成训练集和测试集
load('ORL.mat');
[ROW,COL]=size(data);
N = sqrt(COL);%图片大小
train_h = []; 
test_h = [];
train_label = [];
test_label = [];
% 选前五张为训练集，后五张为测试集
for i = 1:ROW
    if mod(i,10)>=1 && mod(i,10)<=5
        train_h = [train_h;data(i,:)];
        train_label = [train_label;label(i,:)];
    else
        test_h = [test_h;data(i,:)];
        test_label = [test_label;label(i,:)];
    end
end
%% 数据预处理
% 人脸行到列
train = train_h';
test = test_h';

% 每行减去对应向量的平均值
img_num = ROW/2; % 训练集图片数量
img_mean = mean(train,2); % mean每一行均值的列向量
% 得到平均脸
% mean_face = reshape(img_mean,[N,N]);
% imshow(mean_face,[]);
differ = [];
for i = 1:img_num
   temp = train(:,i)-img_mean; 
   differ = [differ temp];% 加一列
end

%% 求协方差矩阵的特征向量，建立特征脸
L = (differ' * differ);
[eiv,eic] = eig(L);   %求取特征向量eiv以及特征值eic

%得到协方差矩阵的特征向量组成的投影子空间,归一化
eiv=differ*eiv;
eiv=normalize(eiv);

% 对特征值排序
eic_sort=diag(eic);
L_eig = eiv(:,200-d+1:200);
% 降维
ei_face = L_eig;     
project = ei_face' * differ;

% 显示特征脸
% temp_ei_face = [];
% for i = 1:10
%     temp_ei_face = reshape(ei_face(:,i),[128,128]);
%     subplot(3,4,i);
%     imshow(temp_ei_face,[]);
% end

%% 最邻近分类

%投影被识别图片
% project_test = [ ];
% test_index = 198;
% temp_mat = test_h(test_index,:);
% temp_mat = reshape(temp_mat,[N,N]);
% figure,imshow(temp_mat,[]);
% title('Test Image');
% temp_mat = reshape(temp_mat,[N*N,1]);
% temp_mat = double(temp_mat) - img_mean;
% project_test = ei_face' * temp_mat;
% 
% % 算取欧式距离
% com_dist = [ ];
% for i = 1:img_num
%     vec_dist = norm(project_test - project(:,i));
%     com_dist = [com_dist vec_dist];
% end
% 
% % 筛选出距离最小的样本图片
% [match_min,match_index] = min(com_dist);
% match_index
% recognize_img = train_h(match_index,:);
% recognize_img = reshape(recognize_img,[N,N]);
% figure,imshow(recognize_img,[]);
% title('Recognized Image');

%% 计算识别正确率
right = 0;
total = img_num;
for test_index = 1:total
    % 投影被识别图片
    project_test = [ ];
    temp_mat = test(:,test_index);
    temp_mat = double(temp_mat) - img_mean;
    project_test = ei_face' * temp_mat;

    % 算取欧式距离
    com_dist = [ ];
    for i = 1:img_num
        vec_dist = norm(project_test - project(:,i));
        com_dist = [com_dist vec_dist];
    end

    % 筛选出距离最小的样本图片
    [match_min,match_index] = min(com_dist);
    if train_label(match_index) == test_label(test_index)
        right = right + 1;
    end
end
rate = right/total;
end