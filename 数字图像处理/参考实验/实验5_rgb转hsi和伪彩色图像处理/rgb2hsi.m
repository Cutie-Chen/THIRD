% 输入图像是一个彩色像素的M×N×3的数组，
% 输入图像可能是double（取值范围是[0, 1]），uint8或 uint16。
% 输出HSI图像是double，
% 其中hsi(:, :, 1)是色度分量，它的范围是除以2*pi后的[0, 1]；
% hsi(:, :, 2)是饱和度分量，范围是[0, 1]；
% hsi(:, :, 3)是亮度分量，范围是[0, 1]。
function rgb2hsi(filename)
% 抽取图像分量
rgb = imread(filename);

rgb = im2double(rgb);
r = rgb(:, :, 1);
g = rgb(:, :, 2);
b = rgb(:, :, 3);
 
% H
num = 0.5*((r - g) + (r - b));
den = sqrt((r - g).^2 + (r - b).*(g - b));
theta = acos(num./den); 
H = theta;
H(b > g) = 2*pi - H(b > g);
H = H./(2*pi);
% S
num = min(min(r, g), b);
den = r + g + b;
S = 1 - 3.* num./den;
% I
I = (r + g + b)/3;

subplot(2,2,1); imshow(rgb); title('RGB');
subplot(2,2,2); imshow(H,[]); title('H');
subplot(2,2,3); imshow(S,[]); title('S');
subplot(2,2,4); imshow(I,[]); title('I');
end