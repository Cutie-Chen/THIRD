function result = my_conv(f,w)

f=imread('building.tif');

if ~isa(f,'double')
    img = double(f);
else
    img = f;
end

kernel = rot90(rot90(w));
[rkernel, ckernel] = size(w);
[rimg, cimg] = size(img);
 
% 卷积核中心元素
rker_center = round(rkernel/2); 
cker_center = round(ckernel/2);
 
% 增广图像原始数据
append = zeros(rimg + rkernel - 1, cimg + ckernel - 1);
append(rker_center : rker_center + rimg - 1, cker_center : cker_center + cimg - 1) = img;
 
% 计算增广后的图像数据大小
[rappend, cappend] = size(append);
conv_result = zeros(rappend, cappend);
for m = rker_center:rker_center + rimg - 1
    for n = cker_center:cker_center + cimg - 1
        data_mid = append(m-(rker_center - 1) : m+(rker_center - 1), n-(rker_center - 1):n+(rker_center-1));
        conv_operation = sum(kernel.*data_mid);
        conv_result(m, n) = sum(conv_operation(:));
    end 
end
% 删去之前增广的0边
result = conv_result(rker_center : rker_center + rimg - 1, cker_center : cker_center + cimg - 1);
end
