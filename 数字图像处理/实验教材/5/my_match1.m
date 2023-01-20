function [] = my_match(source_img, target_img)
    % Level为灰度级别
    % T1, T2分别为输入图像，模板直方图的均衡化用到的变换向量
    % T3为输入图像匹配模板直方图用到的变换向量
    Level = 256;
    %读取图像
    source_img=imread(source_img);
    target_img=imread(target_img);
    [m, n] = size(source_img);
    %图像直方图
    source_hist = imhist(source_img);
    target_hist=imhist(target_img);
    % 求解T1
    ac1 = zeros(Level, 1);
    T1 = zeros(Level, 1, 'uint8');
    ac1(1) = source_hist(1);
    for i = 2 : Level
        ac1(i) = ac1(i - 1) + source_hist(i);
    end
    ac1 = ac1 * (Level - 1);
    for i = 1 : 256
        T1(i) = uint8(round((ac1(i)) / (m * n)));
    end
    % 求解T2
    ac2 = zeros(Level, 1);
    T2 = zeros(Level, 1, 'uint8');
    ac2(1) = target_hist(1);
    for i = 2 : Level
        ac2(i) = ac2(i - 1) + target_hist(i);
    end
    ac2 = ac2 * (Level - 1);
    hist_sum = sum(target_hist);
    for i = 1 : 256
        T2(i) = uint8(round((ac2(i)) / hist_sum));
    end
    % 求解T3
    % T1映射到T2^(-1)时，若有多个值，选取最小的那个值。
    % 产生0 到 255 之间的256个点，即产生0,1,2,...,255的大小为256的数组
    temp = zeros(Level, 1, 'uint8');
    T3 = T1;
    for i = 1 : 256
        for j = 1 : 256
            temp(j) = abs(T1(i) - T2(j));
        end
        [~, B] = min(temp);
        T3(i) = B - 1;
    end
    % 根据T3转换输入图像的值
    for i = 1 : m
        for j = 1 : n
            image_out(i, j) = T3(uint32(source_img(i, j)) + 1);
        end
    end
 
    figure;
    subplot(2, 3, 1), imshow(source_img), title('原图像');
    subplot(2, 3, 2), imshow(target_img), title('模板图像');
    subplot(2, 3, 3), imshow(image_out), title('匹配后得到的图像');
    subplot(2, 3, 4), imhist(source_img), title('原图像的直方图');
    subplot(2, 3, 5), imhist(target_img), title('模板图像的直方图');
    subplot(2, 3, 6), imhist(image_out), title('匹配后的直方图');
    end