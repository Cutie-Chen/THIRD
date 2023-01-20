img=imread("Fig0630(01)(strawberries_fullcolor).tif");%读取图像
%rgb转hsi
rgb=im2double(img);
r=rgb(:,:,1);
g=rgb(:,:,2);
b=rgb(:,:,3);
%计算H，弧度
h1=0.5*((r-g)+(r-b));
h2=sqrt((r-g).^2+(r-b).*(g-b));
theta=acos(h1./(h2+eps)); %分母+eps防止为0  acos得到的是弧度
H0=theta.*(g>=b);   %G>=B
H1=(2*pi-theta).*(g<b);  %G<B
H=H0+H1;
H=H/(2*pi);%将H转成角度
%计算S
s=3.*min(min(r,g),b);
S=1-s./(r+g+b+eps);
%计算I
I=(r+g+b)/3;
hsi=cat(3,H,S,I);

%hsi转rgb
H = hsi(:, :, 1) * 2 * pi; 
S = hsi(:, :, 2); 
I = hsi(:, :, 3); 
R = zeros(size(hsi, 1), size(hsi, 2)); 
G = zeros(size(hsi, 1), size(hsi, 2)); 
B = zeros(size(hsi, 1), size(hsi, 2)); 
%当h在0~120时
h = find( (0 <= H) & (H < 2*pi/3)); 
B(h) = I(h) .* (1 - S(h)); 
R(h) = I(h) .* (1 + S(h) .* cos(H(h)) ./ cos(pi/3 - H(h))); 
G(h) = 3*I(h) - (R(h) + B(h)); 
%当h在120~240时
h = find( (2*pi/3 <= H) & (H < 4*pi/3) ); 
R(h) = I(h) .* (1 - S(h)); 
G(h) = I(h) .* (1 + S(h) .* cos(H(h) - 2*pi/3) ./ cos(pi - H(h))); 
B(h) = 3*I(h) - (R(h) + G(h)); 
%当h在240~300时
h = find( (4*pi/3 <= H) & (H <= 2*pi)); 
G(h) = I(h) .* (1 - S(h)); 
B(h) = I(h) .* (1 + S(h) .* cos(H(h) - 4*pi/3) ./cos(5*pi/3 - H(h))); 
R(h) = 3*I(h) - (G(h) + B(h)); 

rgb = cat(3, R, G, B); 
rgb = max(min(rgb, 1), 0); 
 
subplot(121)
imshow(img);
title("原始图像");
subplot(122);
imshow(rgb);
title("转换到RGB的图像");