function trajectory = randomWalk(sizeX,sizeY,speed,timesteps)

init_points = [ceil(sizeY/2),ceil(sizeX/2)];
livePoints = init_points;
trajectory = zeros(2,timesteps);
moveMat = speed*round(randn(2,1));
testMat = zeros(sizeY,sizeX);
    for it = 1:timesteps
        % indices = sub2ind(size(testMat),livePoints(1),livePoints(2));
        trajectory(1,it) = livePoints(1);
        trajectory(2,it) = livePoints(2);
        % testMat(:) = 0;
        % testMat(indices) = 1;
        points = livePoints;
        check = 0;
    
        while check == 0
            moveMat = speed*round(randn(1,2));
            livePoints = points+moveMat;
            if livePoints(1) < 0
                continue;
            end
    
            if livePoints(2) < 0
                continue;
            end
    
            if livePoints(1) >= sizeX
                continue;
            end
    
            if livePoints(2) >= sizeY
                continue;
            end
            check = 1;
        end
    
    end
end

