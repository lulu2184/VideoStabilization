function transH = DPSmoothPath(detX, detY, angle, transH, n_frame)
    lb = 20;
    
    f = zeros(1, n_frame);
    des = zeros(1, n_frame);
    des(1) = -1;
    for i = 2:lb, f(i) = 1e100; des(i) = -1; end; 
    for i = lb + 1:n_frame
        disp(i);
        f(i) = 1e100;
        for j = 1: i - lb
            w = f(j) + calculateWeight(detX, detY, angle, j, i);
            if w < f(i), f(i) = w; des(i) = j; end;
        end;
    end;
    
    pos = n_frame;
    while pos > 0
        disp(pos);
        old = des(pos);
        if old < 0, break; end;
        new = pos;
        for j = 0:new - old - 1
            dx = (detX{new} - detX{old})/(new - old);
            dy = (detY{new} - detY{old})/(new - old);
            da = (angle{new} - angle{old})/(new - old);
            for k = 1:new - old - 1
                a = k * da;
                uMat = [cos(a), -sin(a), 0; sin(a), cos(a), 0; dx * k, dy * k, 1];
                T = uMat * transH{old};
                transH{old + k} = T;
            end;
        end;
        pos = old;
    end;

function value = calculateWeight(detX, detY, angle, old, new)
    dx = (detX{new} - detX{old})/(new - old);
    dy = (detY{new} - detY{old})/(new - old);
    da = (angle{new} - angle{old})/(new - old);
    value = 0;
    for k = 0 : new - old - 1
        a = k * da;
        value = value + calculation(dx * k + detX{old} - detX{k + old}, ...
            dy * k + detY{old} - detY{k + old}, a + angle{old} - angle{k + old});
    end;
    value = value / (new - old + 1)^2;

function value = calculation(dx, dy, da)
    value = dx^2 + dy^2 + (da * 5);