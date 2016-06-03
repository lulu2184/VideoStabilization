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
transH = {eye(3)};
detX = {0};
detY = {0};
angle = {0};


while ~isDone(videoReader)
    disp(n_frame);
    n_frame = n_frame + 1;
    outA = outB;
    imgA = imgB;
    imgB = step(videoReader);
    H = stabilizationTform(rgb2gray(imgA), rgb2gray(imgB));
    HsRt = cvexTformToSRT(H);

    Hcumulative = HsRt * Hcumulative;
    detX{n_frame} = Hcumulative(3,1);
    detY{n_frame} = Hcumulative(3,2);
    angle{n_frame} = atan2(Hcumulative(1,1), Hcumulative(2,1));
    transH{n_frame} = Hcumulative;
    outB = imwarp(imgB, affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));      
end;

transH = naiveSmoothPath(detX, detY, angle, transH, n_frame);
    
reset(videoReader);
for i = 1:n_frame
    disp(i);
    img = step(videoReader);
    out = imwarp(img, affine2d(transH{i}),'OutputView',imref2d(size(img)));
    out = padarray([out(startm:endm, startn:endn, :)], [startm, startn]);
    out = out(1:m, 1:n, :);
    writeVideo(outVideo, [img, out]);
end;
        
close(outVideo);
release(videoPlayer);
release(videoReader);