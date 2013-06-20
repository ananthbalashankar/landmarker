function newPath  = correctLocation(oldPath, diff, lastLandmark, firstTime, timeSlots,centroid)
   % try
        lastTime = lastLandmark{2};
        lastCentroid = lastLandmark{1};
        xold = oldPath(:,1);
        yold = oldPath(:,2);
        prev(:,1) = xold(timeSlots < firstTime);
        prev(:,2) = yold(timeSlots < firstTime);
        a = timeSlots > lastTime;
        b = timeSlots < firstTime;
        c = a .* b;
        currTime = timeSlots(c==1)';
        if(firstTime ~= lastTime)
            next(:,1) = xold(timeSlots >= firstTime);
            next(:,2) = yold(timeSlots >= firstTime);
            nextPath(:,1) = next(:,1) + diff(1);
            nextPath(:,2) = next(:,2) + diff(2);
            currPath = interp1([lastTime;firstTime] , [lastCentroid;centroid], currTime);
            newPath = [prev;nextPath];
        else
            next(:,1) = xold(timeSlots >= firstTime);
            next(:,2) = yold(timeSlots >= firstTime);
            nextPath(:,1) = next(:,1) + diff(1);
            nextPath(:,2) = next(:,2) + diff(2);
            newPath = [prev;nextPath];
        end
%     catch
%         disp('err');
%         
%     end
    
end