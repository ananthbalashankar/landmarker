function combined = combineClusters( new , stable , correctionVector)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 feature = new{1};
 numPoints = new{3};
 location = new{4};
 location(:,1) = location(:,1) + correctionVector(1);
 location(:,2) = location(:,2) + correctionVector(2);
 timeSlots = new{5};
 initialTime = new{6};
 
 SnumPoints = stable{3};
 Slocation = stable{4};
 StimeSlots = stable{5};
 SinitialTime = stable{6};
 factor = stable{8};
 
 time1 = (timeSlots - initialTime);
 time2 = (StimeSlots - SinitialTime);
 feat = new{7};
 Sfeat = stable{7};
 stableFeat = [];
 
 j=1;
 stableLoc = [];
 for i=1:size(time1,2)
    while(j< size(time2,2) && time2(j) < time1(i))
        j = j+1;
    end
    stableLoc(i,1) = (location(i,1) + factor*Slocation(j,1))/(factor+1);
    stableLoc(i,2) = (location(i,2) + factor*Slocation(j,2))/(factor+1);
    stableFeat(i,:) = (feat(i,:)+factor*Sfeat(j,:))/(1+factor);
 end
 
 centroidx = 0; centroidy = 0;
 for i=1:size(time1,2)
    centroidx = centroidx + stableLoc(i,1);
    centroidy = centroidy + stableLoc(i,2);
 end
 
 centroidx = centroidx / size(time1,2);
centroidy = centroidy / size(time1,2);
distance = pdist2([centroidx centroidy], stableLoc);
xaxis = stableLoc(:,1);
combinedLocx = xaxis(distance<2);
yaxis = stableLoc(:,2);
combinedLocy = yaxis(distance<2);

combinedTime = time1(distance<2);
combinedTime = combinedTime+SinitialTime;

combinedPoints = length(combinedLocx);
newStableFeat = [];
for j=1:size(stableFeat,2)
    feat = stableFeat(:,j);
    newStableFeat(:,j) = feat(distance <2);
end

combined = {feature, [centroidx centroidy], combinedPoints, [combinedLocx combinedLocy], combinedTime, SinitialTime, newStableFeat ,factor+1 };

end

