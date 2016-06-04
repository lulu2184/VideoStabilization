function img = padding(img, img_trans, index, transH, array_img)
    Mat = eye(3);
    complement = single(zeros(size(img, 1), size(img, 2), 3));
    counter = zeros(size(img, 1), size(img, 2));
    blender = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');
    for i = index-1:-1:1
        Mat = transH{i + 1}^(-1) * Mat;
        Mat(:,3) = [0; 0; 1];
        tmp = imwarp(array_img{i}, affine2d(Mat  * img_trans),'OutputView',imref2d(size(img)));
        complement = step(blender, complement, tmp, tmp(:, :, 1));
%         for j = 1:size(img, 1)
%             for k = 1:size(img, 2)
%                 if ~isequal(tmp(j, k, :), zeros(1, 1, 3))
%                     complement(j, k, :) = complement(j, k, :) + tmp(j, k, :);
%                     counter(j, k) = counter(j, k) + 1;
%                 end;
%             end;
%         end;
    end;
    
    Mat = eye(3);
    for i = index+1:size(transH, 2)
        Mat = transH{i} * Mat;
        tmp = imwarp(array_img{i}, affine2d(Mat * img_trans),'OutputView',imref2d(size(img)));
        complement = step(blender, complement, tmp, tmp(:, :, 1));
%         for j = 1:size(img, 1)
%             for k = 1:size(img, 2)
%                 if ~isequal(tmp(j, k, :), zeros(1,1,3))
%                     complement(j, k, :) = complement(j, k, :) + tmp(j, k, :);
%                     counter(j, k) = counter(j, k) + 1;
%                 end;
%             end;
%         end;
    end;
    
    for i = 1:size(img, 1)
        for j = 1:size(img, 2)
            if rgb2gray(img(i, j, :)) < 0.05, img(i,j,:) = complement(i, j, :);
            else img(i,j,:) = img(i,j,:);end;
%             if img(i, j, :), zeros(1,1,3))
%                 disp(i, ' ', j, 'bbb');
%             end;
        end;
    end;
    img = single(img);