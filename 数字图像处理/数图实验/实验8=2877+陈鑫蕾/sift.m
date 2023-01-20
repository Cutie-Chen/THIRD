function [image, des, loc] = sift(image)
% image: grayscal
% length: 第i组第j层特征点(ii,jj)的主梯度幅值
% direction: 第i组第j层特征点(ii,jj)的主梯度方向
% aaa: 特征点坐标集合
% des_idxs: 第i组第j层特征点(ii,jj)的描述子索引
% descriptions: 上面索引对应的128维描述子

% 读取图像并转化为灰度图像
 %image = imread(image);
[rows, cols, channels] = size(image);
if channels~=1
    image = rgb2gray(image);
end
[rows, cols] = size(image);

% 构建高斯金字塔
octave = floor(log2(min(rows, cols)))-3;
s = 3;
sigama0=1.6;
k=2^(1/s);
%image0 = imresize(image, 2, 'nearest'); % 先将原图像长、宽各扩展一倍
image0=image;
gauss_pyr_img = cell(octave+1, s+3);
for i=1:octave+1
    if i==1
        image0 = image0;
    else
        image0 = imresize(gauss_pyr_img{i-1}{s+1}, 0.5, 'nearest');
    end
    sigama1 = sigama0*2^(i-1);
    for j=1:s+3
        sigama = sigama1*k^(j-1);
        gauss_pyr_img{i}{j} = gauss(image0, sigama);
    end
end

% 构建高斯差分金字塔
DoG_pyr_img = cell(octave+1, s+2);
for i=1:octave+1
    for j=1:s+2
        DoG_pyr_img{i}{j} = gauss_pyr_img{i}{j+1}-gauss_pyr_img{i}{j};
    end
end

% DoG空间极值探测并去除低对比度的边缘相应点
location = cell(size(DoG_pyr_img));
curvature_threshold = 10.0;
curvature_threshold = (curvature_threshold+1)^2/curvature_threshold; % 主曲率阈值
contrast_threshold = 0.03; % 对比度阈值
xx = [1 -2 1];
yy = xx';
xy = [-1 0 1; 0 0 0; 1 0 -1]/4;
for i=1:octave+1
    [M, N] = size(DoG_pyr_img{i}{1});
    for j=2:s+1
        contrast_mask = abs(DoG_pyr_img{i}{j}(:,:))>=contrast_threshold;
        location{i}{j-1} = zeros(M,N);
        for ii=2:M-1
            for jj=2:N-1
                if(contrast_mask(ii, jj)==1)
                    tmp1 = DoG_pyr_img{i}{j-1}((ii-1):(ii+1),(jj-1):(jj+1));
                    tmp2 = DoG_pyr_img{i}{j}((ii-1):(ii+1),(jj-1):(jj+1));
                    tmp3 = DoG_pyr_img{i}{j+1}((ii-1):(ii+1),(jj-1):(jj+1));
                    tmp = [tmp1;tmp2;tmp3];
                    center = tmp2(2,2);
                    if(center==max(tmp(:)) || center==min(tmp(:)))
                        Dxx = sum(tmp2(2,1:3).*xx);
                        Dyy = sum(tmp2(1:3,2).*yy);
                        Dxy = sum(sum(tmp2(:,:).*xy));
                        TrH = Dxx+Dyy;
                        DetH = Dxx*Dyy-(Dxy)^2;
                        curvature = (TrH^2)/DetH;
                        if(curvature<curvature_threshold)
                            location{i}{j-1}(ii, jj) = 255;
                        end
                    end
                end
            end
        end
    end
end

% 求取特征点的主方向
length = cell(size(location));
direction = cell(size(location));
sigama0 = 1.6;
count = 0; % 设置一个计数器，用来确定计算以特征点为中心图像幅角和幅值的区域半径
hist = zeros(1, 36); % 统计邻域内梯度方向直方图
for i=1:octave+1
    [M, N] = size(gauss_pyr_img{i}{1});
    for j=2:s+1
        count = count+1;
        % 尺度变化的连续性
        % 上一组极值采样的最后一项是2^(i-1)*k^3*σ=2^i*σ，下一组极值采样的第一项是2^i*k^1*σ=2^(i+1/3)*σ，连续起来
        sigama = sigama0*k^count; 
        length{i}{j-1} = zeros(M, N);
        direction{i}{j-1} = zeros(M, N);
        r = 8; % 区域半径设为8
        for ii=r+2:M-r-1
            for jj=r+2:N-r-1
                if(location{i}{j-1}(ii, jj)==255)
                    % 计算当前关键点(ii,jj)为中心、r为半径的图像梯度主方向和幅值
                    for iii=ii-r:ii+r
                        for jjj=jj-r:jj+r                          
                            m = sqrt((gauss_pyr_img{i}{j}(iii+1, jjj)-gauss_pyr_img{i}{j}(iii-1,jjj))^2+(gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))^2);
                            theta = atan((gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))/(gauss_pyr_img{i}{j}(iii+1, jjj)-gauss_pyr_img{i}{j}(iii-1,jjj)));
                            theta = theta/pi*180;
                            if(theta<0)
                                theta = theta+360;
                            end
                            w = exp(-((iii-ii)^2+(jjj-jj)^2)/(2*(1.5*sigama)^2)); % 生成邻域各像元的高斯权重，距离越近权重越大
                            if(isnan(theta))
                                if((gauss_pyr_img{i}{j}(iii, jjj+1)-gauss_pyr_img{i}{j}(iii, jjj-1))>=0)
                                    theta=90;
                                else
                                    theta=270;
                                end
                            end
                            t=floor(theta/10)+1;
                            hist(t) = hist(t)+m*w; % 将幅值*高斯权重加入对应的直方图中
                        end
                    end
                    % opencv直方图平滑，防止某个梯度方向角度因受到噪声的干扰二突变，角度是循环的
                    hist_smooth = zeros(1,36);
                    hist_smooth(1) = (hist(35)+hist(3)+4*hist(36)+4*hist(2)+6*hist(1))/16;
                    hist_smooth(2) = (hist(36)+hist(4)+4*hist(1)+4*hist(3)+6*hist(2))/16;
                    for h=3:34
                        hist_smooth(h) = (hist(h-2)+hist(h+2)+4*hist(h-1)+4*hist(h+1)+6*hist(h))/16;
                    end
                    hist_smooth(35) = (hist(33)+hist(1)+4*hist(34)+4*hist(36)+6*hist(35))/16;
                    hist_smooth(36) = (hist(34)+hist(2)+4*hist(35)+4*hist(1)+6*hist(36))/16;
                    hist = hist_smooth;
                    
                    % 主方向max(hist(i))是一个范围，利用hist(i)、hist(i-1)、hist(i+1)三个点绘制抛物线，获得精确的主方向
                    % h(t)=a*t^2+b*t+c, t∈[-1,1]
                    % a=(h(1)+h(-1))/2-h(0)
                    % b=(h(1)-h(-1))/2
                    % c=h(0)
                    % 则精确主方向：v-b/2a
                    [u, v] = max(hist(:)); % [幅值 幅角索引]=max(hist())
                    h0=hist(v);
                    if(v==36)
                        h1=hist(1);
                    else
                        h1=hist(v+1);
                    end
                    if(v==1)
                        h_1=hist(36);
                    else
                        h_1=hist(v-1);
                    end
                    v = v-(h1-h_1)/(2*(h1+h_1-2*h0));
                    length{i}{j-1}(ii,jj) = u;
                    direction{i}{j-1}(ii,jj) = floor((v-1)*10);
                end
            end
        end
    end
end

% 特征描述符的生成
sigama0=1.6;
count=0;
des_idxs = cell(size(location)); % 描述子的索引
descriptions=[]; % 描述子
index=0; % 索引变量
d=[]; % 存储每个像素梯度的方向
l=[]; % 存储每个像素梯度的幅值
f=zeros(1,8); % 用来存放每个子区域的8维描述子
description=[]; % 用来存放单个关键点的4*4领域的描述子，4*4*8=128
aaa=[];
for i=1:octave+1
    [M, N] = size(gauss_pyr_img{i}{1});
    for j=2:s+1
        des_idxs{i}{j-1} = zeros(M,N);
        count = count+1;
        sigama = sigama0*k^count;
        r=8; % 描述子范围，4*4领域，一个子区域是4*4个像素点
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % . . . . . . . . . . . . . . . . . . .
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % . . . . . . . . . X . . . . . . . . .
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % . . . . . . . . . . . . . . . . . . .
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        % 1 1 1 1 . 1 1 1 1 . 1 1 1 1 . 1 1 1 1
        for ii=r+2:M-r-1
            for jj=r+2:N-r-1
                if(length{i}{j-1}(ii,jj)~=0)
                    theta_1 = direction{i}{j-1}(ii,jj);
                    index = index+1;
                    description=[];
                    d=[];
                    l=[];
                    % 计算当前特征点为中心、r为半径的邻域内每个像素的梯度方向，
                    for iii=[ii-r:1:ii-1,ii+1:1:ii+r]
                        for jjj=[jj-r:1:jj-1,jj+1:1:jj+r]
                            m = sqrt((gauss_pyr_img{i}{j}(iii+1,jjj)-gauss_pyr_img{i}{j}(iii-1,jjj))^2+(gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))^2);
                            theta = atan((gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))/(gauss_pyr_img{i}{j}(iii+1,jjj)-gauss_pyr_img{i}{j}(iii-1,jjj)));
                            theta = theta/pi*180;
                            if(theta<0)
                                theta = theta+360;
                            end
                            w = exp(-((iii-ii)^2+(jjj-jj)^2)/(2*(1.5*sigama)^2)); % 生成邻域各像元的高斯权重
                            if(isnan(theta))
                                if((gauss_pyr_img{i}{j}(iii,jjj+1)-gauss_pyr_img{i}{j}(iii,jjj-1))>=0)
                                    theta=90;
                                else
                                    theta=270;
                                end
                            end
                            theta = theta+360-theta_1; % 逆时针旋转至主方向
                            theta = mod(theta, 360);
                            d = [d,theta];
                            l = [l,m*w];
                        end
                    end
                    d = reshape(d,16,16); % 8*8*4
                    l = reshape(l,16,16);
                    for r1=1:4
                        for c1=1:4
                            % 每个子区域的8个方向的梯度值
                            for iiii=1+(r1-1)*4:4*r1
                                for jjjj=1+(c1-1)*4:4*c1
                                    t = floor(d(iiii,jjjj)/45+1);
                                    f(t) = f(t)+l(iiii,jjjj);
                                end
                            end
                            description = [description, f(:)]; % 4*4*128
                        end
                    end
                    description = description./sqrt(sum(description(:).*description(:))); % 描述子归一化
                    descriptions = [descriptions;description(:)];
                    des_idxs{i}{j-1}(ii,jj)=index;
                    aaa = [aaa;ii,jj];
                end
            end
        end
    end
end
descriptions = reshape(descriptions,[],128); % 描述子变为128维

% 提取差分金字塔的第1组第2层的特征。
des=[];
loc=[];
[M, N] = size(gauss_pyr_img{1}{1});
for i=1:M
    for j=1:N
        if(length{1}{1}(i,j)~=0)
            loc=[loc;i,j];
            idx=des_idxs{1}{1}(i,j);
            des=[des;direction{1}{1}(i,j),length{1}{1}(i,j),descriptions(idx,:)];
        end
    end
end

end

                    

