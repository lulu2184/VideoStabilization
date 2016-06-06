function img = padding(img, img_trans, index, transH, array_img)
    Mat = eye(3);
    complement = single(zeros(size(img, 1), size(img, 2), 3));
    blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');
    for i = index-1:-1:1
        Mat = Mat * transH{i + 1}^(-1);
        Mat(:,3) = [0; 0; 1];
        tmp = imwarp(array_img{i}, affine2d(img_trans * Mat),'OutputView',imref2d(size(img)));
        complement = step(blender, tmp, complement, complement(:, :, 1));
    end;
    
    Mat = eye(3);
    for i = index+1:size(transH, 2)
        Mat = Mat * transH{i};
        tmp = imwarp(array_img{i}, affine2d(img_trans * Mat),'OutputView',imref2d(size(img)));
        complement = step(blender, complement, tmp, tmp(:, :, 1));
    end;
    
    img = step(blender, complement, img, rgb2gray(img));
%     for i = 1:size(img, 1)
%         for j = 1:size(img, 2)
%             if ~(2<=x && x<=m - 1 && 2<=y && y<=n - 1), img(i,j,:) = complement(i, j, :); end;
%         end;
%     end;
    img = single(img);