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

residue_scale = 0.1;
[m, n, tn] = size(imgB);
startm = round(m * residue_scale);
endm = m - round(m * residue_scale);
startn = round(n * residue_scale);
endn = n - round(n * residue_scale);
n_frame = 1;
transH = {eye(3)};
img_array = {imgB};
detY = zeros(390);
detA = zeros(390);

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
    transH{n_frame} = H;
    detY(n_frame) = Hcumulative(3, 2);
    detA(n_frame) = atan2(Hcumulative(2,1), Hcumulative(1,1));
%     outB = imwarp(imgB, affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));      
end;

[final_transH, keyframe] = DPSmoothPath(transH, n_frame);

T_axis = 1:n_frame;
figure;
plot(T_axis, detY(1:n_frame), keyframe, detY(keyframe))
xlabel('frame')
ylabel('Motion in y')

figure;
plot(T_axis, detA(1:n_frame), keyframe, detA(keyframe))
xlabel('frame')
ylabel('Motion in rotation')


window_size = 30;
    
reset(videoReader);
for i = 1:n_frame
    disp(i);
%     disp(transH{i});
    img = step(videoReader);
    out = imwarp(img, affine2d(final_transH{i}),'OutputView',imref2d(size(img)));
    origin_out = out;

    left = max(1, i - window_size / 2);
    right = min(n_frame, i + window_size / 2);
    out = padding(out, final_transH{i}, i - left + 1, transH(left:right), img_array(left:right));
    out = padarray([out(startm:endm, startn:endn, :)], [startm, startn]);
    out = insertText(out, [1 1], [i]);
    out = out(1:m, 1:n, :);
    
    writeVideo(outVideo, [origin_out, out]);
end;
        
close(outVideo);
release(videoPlayer);
release(videoReader);