% 高斯卷积操作
function y = gauss(x, sigama)
n = round(6*sigama);
if mod(n, 2)==0
    n=n+1;
end
h=fspecial('gaussian',[n,n],sigama);
y=filter2(h, x);