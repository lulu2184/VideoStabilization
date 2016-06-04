function transH = naiveSmoothPath(detX, detY, angle, transH, n_frame)
    
    gap = 20;
    for i = 1:n_frame/gap
        old = (i-1)*gap + 1;
        new = min(i*gap + 1, n_frame);
        if old == new, break; end;
        dx = 0;
        dy = 0;
        da = 0;
        Mat = eye(3);
        for j = 1: new - old - 1
%             dx = dx + detX{j + old};
%             dy = dy + detY{j + old};
%             da = da + angle{j + old};
            Mat = transH{j + old} * Mat;
        end;
%         dx = - dx / (new - old);
%         dy = - dy / (new - old);
%         da = - (da - floor(da/pi) * pi) / (new - old);
%         dx = (detX{new} - detX{old})/(new - old);
%         dy = (detY{new} - detY{old})/(new - old);
%         da = (angle{new} - angle{old})/(new - old);
%         uMat = transH{old}^(-1);
        transH{old} = eye(3);
%         detX{old} = 0;
%         detY{old} = 0;
%         angle{old} = 0;
%         TT = transH{old}^(-1);
        uMat = Mat^(-1/(new - old));
        for j = 1:new - old - 1
%             a = j * da;
%             detX{old + j} = detX{old + j - 1} + detX{old + j} + dx;
%             detY{old + j} = detY{old + j - 1} + detY{old + j} + dy;
%             angle{old + j} = angle{old + j - 1} + angle{old + j} + da;
%             uMat = [cos(da), -sin(da), 0; sin(da), cos(da), 0; dx, dy, 1];
%             T = transH{old + j} * uMat * transH{old + j -1};
%             T(1, 3) = 0;
%             T(2, 3) = 0;
%             T(3, 3) = 1;  
%             a = angle{old + j};
%             transH{old + j} = [cos(a), -sin(a), 0; sin(a), cos(a), 0; detX{old + j}, detY{old + j}, 1];
            transH{old + j} = transH{old + j} * transH{old + j - 1};
        end;
        cMat = uMat;
        for j = 1:new - old - 1
            transH{old + j} = cMat * transH{old + j};
            cMat = cMat * uMat;
        end;
    end;

end
