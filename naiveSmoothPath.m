function transH = naiveSmoothPath(transH, n_frame)
    
    gap = 20;
    for i = 1:n_frame/gap
        old = (i-1)*gap + 1;
        new = min(i*gap + 1, n_frame);
        if old == new, break; end;
        Mat = eye(3);
        for j = 1: new - old
            Mat = transH{j + old} * Mat;
        end;
        transH{old} = eye(3);
        uMat = Mat^(-1/(new - old));
        for j = 1:new - old - 1
            transH{old + j} = transH{old + j} * transH{old + j - 1};
        end;
        cMat = uMat;
        for j = 1:new - old - 1
            transH{old + j} = cMat * transH{old + j};
            cMat = cMat * uMat;
        end;
    end;

end
