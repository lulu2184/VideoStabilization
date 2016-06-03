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
startm = round(m * 0.15);
endm = m - round(m * 0.15);
startn = round(n * 0.15);
endn = n - round(n * 0.15);
n_frame = 0;
transH = [eye(3)];
detX, detY, angle = [0];
img_array = [imgB];

while ~isDone(videoReader)
    disp(n_frame);
    n_frame = n_frame + 1;
%     imgB = step(converter, frame);
    outA = outB;
    imgA = imgB;
    imgB = step(videoReader);
%     if mod(n, 50) == 0
%         Hcumulative = eye(3);
%         imgA = imgB; 
%     end;
%     if i == 3, imshow(imfuse(imgA, imgB,'ColorChannels','red-cyan'));end;
    H = stabilizationTform(rgb2gray(imgA), rgb2gray(imgB));
    HsRt = cvexTformToSRT(H);
    transH = [transH, HsRt];

    Hcumulative = HsRt * Hcumulative;
    detX = Hcumulative(1,3);
    detY = Hcumulative(2,3);
    angle = atan2(Hcumulative(1,1), Hcumulative(2,1));
%     Hcumulative = HsRt;
    outB = imwarp(imgB, affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
        
    img_array = [img_array, outB];
    step(videoPlayer, outA);

    writeVideo(outVideo, [outB(startm:endm, startn:endn, :)]);
%     step(videoPlayer, imfuse(outA, outB,'ColorChannels','red-cyan'));
end;

detX = smoothPath(detX, n_frame);
detY = smoothPath(detY, n_frame);
angle = smoothPath(angle, n_frame);

gap = 30;
for i = 1:n_frame/gap
    old = (i-1)*gap;
    new = i*gap;
    dx = -(detX(new) - detX(old))/30;
    dy = -(detY(new) - detY(old))/30;
    da = -(angle(new) - angle(old))/30;
    uMat = transH(old)^(-1);
    for j = 0:gap - 1
        transH(old + j) = uMat * transH(old + j);
        uMat = uMat * [cos(da), -sin(da), dx; sin(da), cos(da), dy];
    end;
end;
    
close(outVideo);
release(videoPlayer);
release(videoReader);