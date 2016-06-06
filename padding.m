function img = padding(img, img_trans, index, transH, array_img)
    Mat = eye(3);
    complement = single(zeros(size(img, 1), size(img, 2), 3));
    blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');
    for i = index-1:-1:1
        Mat = transH{i + 1}^(-1) * Mat;
        Mat(:,3) = [0; 0; 1];
        tmp = imwarp(array_img{i}, affine2d(Mat  * img_trans),'OutputView',imref2d(size(img)));
        complement = step(blender, complement, tmp, tmp(:, :, 1));
    end;
    
    Mat = eye(3);
    for i = index+1:size(transH, 2)
        Mat = transH{i} * Mat;
        tmp = imwarp(array_img{i}, affine2d(Mat * img_trans),'OutputView',imref2d(size(img)));
        complement = step(blender, complement, tmp, tmp(:, :, 1));
    end;
    
    for i = 1:size(img, 1)
        for j = 1:size(img, 2)
            if rgb2gray(img(i, j, :)) < 0.05, img(i,j,:) = complement(i, j, :); end;
        end;
    end;
    img = single(img);