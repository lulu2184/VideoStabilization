videoReader = vision.VideoFileReader('c.mp4');
converter = vision.ImageDataTypeConverter;
shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', 255);
videoPlayer = vision.VideoPlayer('Name', 'Motion Vector');
outVideo = VideoWriter('out.avi');

reset(videoReader);

imgB = step(videoReader);
imgA = imgB;
outB = imgB;
Hcumulative = eye(3);

open(outVideo);
i = 1;

[m, n, tn] = size(imgB);
n_frame = 0;
transH = [eye(3)];
img_array = [imgB];

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');


panorama = zeros([1000 1000 3], 'like', imgB);
panoramaView = imref2d([1000 1000], 1000, 1000);

while ~isDone(videoReader)
    disp(n_frame);
    n_frame = n_frame + 1;
    outA = outB;
    imgA = imgB;
    imgB = step(videoReader);

    H = stabilizationTform(rgb2gray(imgA), rgb2gray(imgB));
    HsRt = cvexTformToSRT(H);
    transH = [transH, HsRt];
    Hcumulative = HsRt * Hcumulative;
    outB = imwarp(imgB, affine2d(Hcumulative),'OutputView', panoramaView);
    
    panorama = step(blender, panoramaView, outB, outB(:,:,1));
        
%     img_array = [img_array, outB];
%     step(videoPlayer, outA);

%     writeVideo(outVideo, [outB(startm:endm, startn:endn, :)]);
end;

imshow(panorama);


close(outVideo);
release(videoPlayer);
release(videoReader);