function dist = wifiSimilarity(data, x, y)
    ssidX = data{1}{x};
    rssiX = data{2}{x};
    ssidY = data{1}{y};
    rssiY = data{2}{y};
    common = intersect(ssidX, ssidY);
    dist = 0;
    sX = [];
    sY =[];
    for i=1:size(common,2)
        for j=1:size(ssidX,2);
            if(strcmp(ssidX{j},common{i})==1)
                sX(i) = rssiX{j};
                break;
            end
        end
        for j=1:size(ssidY,2);
            if(strcmp(ssidY{j},common{i})==1)
                sY(i) = rssiY{j};
                break;
            end
        end
    end
    
    for i=1:size(sX)
        dist = dist + (min(sX(i),sY(i))/max(sX(i),sY(i)));
    end
    dist = dist / (size(ssidX,2)+size(ssidY,2)- size(common,2));
end