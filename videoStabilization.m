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
n_frame = 1;
transH = {eye(3)};
detX = {0};
detY = {0};
angle = {0};
img_array = {imgB};


while ~isDone(videoReader)
    n_frame = n_frame + 1;
    disp(n_frame);
    outA = outB;
    imgA = imgB;
    imgB = step(videoReader);
    H = stabilizationTform(rgb2gray(imgA), rgb2gray(imgB));
    H = cvexTformToSRT(H);
    img_array{n_frame} = imgB;
    Hcumulative = H * Hcumulative;
    detX{n_frame} = H(3,1);
    detY{n_frame} = H(3,2);
    angle{n_frame} = atan2(H(2,1), H(1,1));
    transH{n_frame} = H;
%     outB = imwarp(imgB, affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));      
end;

transH = naiveSmoothPath(detX, detY, angle, transH, n_frame);
    
reset(videoReader);
for i = 1:n_frame
    disp(i);
    disp(transH{i});
    img = step(videoReader);
    out = imwarp(img, affine2d(transH{i}),'OutputView',imref2d(size(img)));
    out = padarray([out(startm:endm, startn:endn, :)], [startm, startn]);
    out = out(1:m, 1:n, :);
    out = insertText(out, [1 1], [i]);
    writeVideo(outVideo, [img, out]);
end;
        
close(outVideo);
release(videoPlayer);
release(videoReader);