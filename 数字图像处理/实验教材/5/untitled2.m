    close all;
    clear all;
    clc;
    source_img = imread('Einstein.tif');
    target_img = imread('test.tif');
    hist = imhist(target_img);
    match=hist_Match(source_img,target_img);
    figure;
    subplot(2, 3, 1), imshow(source_img), title('原图像');
    subplot(2, 3, 2), imshow(target_img), title('模板图像');
    subplot(2, 3, 3), imshow(match), title('匹配后得到的图像');
    subplot(2, 3, 4), imhist(source_img), title('原图像的直方图');
    subplot(2, 3, 5), imhist(target_img), title('模板图像的直方图');
    subplot(2, 3, 6), imhist(match), title('匹配后的直方图');
    