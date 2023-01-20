function show_mp(filename)
img=imread(filename);
I=fft2(im2double(img)); 
I=fftshift(I);     
magnitude=log(abs(I));%图像幅度谱，加log便于显示
phase=log(angle(I)*180/pi);%图像相位谱
spectrum=log(I);
subplot(2,2,1),imshow(img),title('The original image');
subplot(2,2,2),imshow(spectrum,[]),title('Spectrum');
subplot(2,2,3),imshow(magnitude,[]),title('Magnitude');
subplot(2,2,4),imshow(phase,[]),title('Phase');
end