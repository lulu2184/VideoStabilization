function H = stabilizationTform(imgA, imgB)

% imshow(imfuse(imgA, imgB,'ColorChannels','red-cyan'));

pointsA = detectSURFFeatures(imgA, 'NumScaleLevels', 6);
pointsB = detectSURFFeatures(imgB, 'NumScaleLevels', 6);

[featuresA, pointsA] = extractFeatures(imgA, pointsA);
[featuresB, pointsB] = extractFeatures(imgB, pointsB);

indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

% figure;
% showMatchedFeatures(imgA, imgB, pointsA, pointsB);
% legend('A', 'B');

[tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA, 'affine');

% figure;
% showMatchedFeatures(imgA, imwarp(imgB,affine2d(tform.T),'OutputView',imref2d(size(imgB))),...
%     pointsAm, transformPointsForward(tform, pointsBm.Location));
% legend('A', 'B');

H = tform.T;

end