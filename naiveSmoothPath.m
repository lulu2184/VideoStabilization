function transH = naiveSmoothPath(detX, detY, angle, transH, n_frame)
    
    gap = 50;
    for i = 1:n_frame/gap
        old = (i-1)*gap + 1;
        new = min(i*gap + 1, n_frame);
        if old == new, break; end;
        dx = -(detX{new} - detX{old})/(new - old);
        dy = -(detY{new} - detY{old})/(new - old);
        da = -(angle{new} - angle{old})/(new - old);
        uMat = transH{old}^(-1);
        for j = 0:old - new - 1
            T = uMat * transH{old + j};
            T(1, 3) = 0;
            T(2, 3) = 0;
            transH{old + j} = T;
            uMat = uMat * [cos(da), -sin(da), 0; sin(da), cos(da), 0; dx, dy, 1];
        end;
    end;

end
