function reduce_gray_levels(imgpath,reduce_factor)
reduce_factor=3;
    InputImg = imread(imgpath);
    % 完整性约束
    if reduce_factor<0
        reduce_factor=0
    else if reduce_factor>8
            reduce_factor=8
        end
    end
    % 降低灰度级
    dfactor=uint8(2^reduce_factor);
    disp(dfactor);
     disp(InputImg/dfactor);
    OutputImg=(InputImg/dfactor)*dfactor;
    %保存输出图像
    output_filename = ['ctskull-output/Ctskull_OutputImg(gray-',num2str(2^( 9 - reduce_factor)),').tif'];
    imwrite(OutputImg,output_filename);
    % 图像对比
    subplot(1,2,1);
    imshow(InputImg);
    title('灰度级: 256');
    subplot(1,2,2);
    imshow(OutputImg);
    title(['灰度级: ',num2str(2^( 9 - reduce_factor))]);
end