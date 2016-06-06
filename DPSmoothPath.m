function [transH, keyframe] = DPSmoothPath(transH, n_frame)
    lb = 10;
    
    f = zeros(1, n_frame);
    des = zeros(1, n_frame);
    des(1) = -1;
    for i = 2:lb, f(i) = 1e100; des(i) = -1; end; 
    for i = lb + 1:n_frame
        disp(i);
        f(i) = 1e100;
        for j = 1: i - lb
            w = f(j) + calculateWeight(transH, j, i);
            if w < f(i), f(i) = w; des(i) = j; end;
        end;
    end;
    
    keyframe = zeros(n_frame);
    count = 0;
    pos = n_frame;
    while pos > 0
        disp(pos);
        old = des(pos);
        count = count + 1;
        keyframe(count) = pos;
        if old < 0, break; end;
        new = pos;
        transH{old} = eye(3);
        uMat = eye(3);
        for j = 1:new - old, uMat = transH{j + old} * uMat; end;
        uMat = uMat^(-1/(new - old));
        for j = 1:new - old
           transH{j + old} = transH{j + old} * transH{j + old - 1};
        end;
        Mat = eye(3);
        for j = 1: new - old
            Mat = Mat * uMat;
            transH{j + old} = Mat * transH{j + old};
        end;
        pos = old;
    end;
    keyframe = sort(keyframe(1:count));

function value = calculateWeight(transH, old, new)
    uMat = eye(3);
    for k = 1 : new - old
        uMat = transH{k + old} * uMat;
    end;
    uMat = uMat^(1/(new - old));
    uMat = real(uMat);
    Mat = eye(1);
    value = 0;
    for k = 1 : new - old - 1
        transH{k + old} = transH{k + old} * transH{k + old - 1};
        Mat = Mat * uMat;
        dx = transH{k + old}(3, 1) - Mat(3, 1);
        dy = transH{k + old}(3, 2) - Mat(3, 2);
        da = atan2(transH{k + old}(2, 1), transH{k + old}(1, 1));
        da = da - atan2(Mat(2, 1), Mat(1, 1));
        value = value + calculation(dx, dy, da);
    end;
    value = value / (new - old + 1)^2;

function value = calculation(dx, dy, da)
    if da > pi, da = pi * 2 - da; end;
    value = dx^2 + dy^2 + (da^2 * 10);