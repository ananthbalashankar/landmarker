function [stable stableFeat newPath] = getStableClusters(cluster, path, timeSlots, old_stable, old_stableFeat)
    stable =  old_stable;
    stableFeat = old_stableFeat;
    newPath = path;
%     numSamples = size(clusters,2);
%     for i=1:numSamples
%         cluster = clusters{i};
        if(isempty(old_stable))
            i=1;
        else
            i=0;
        end
        
        clusters = {};      %stores the clusters in the order in which they were encountered in the path
        numFeatures = size(cluster,2);
        for j=1:numFeatures
            featClusters = cluster{j};
            if(~isempty(featClusters))
                for n=1:size(featClusters,2)
                    
                    featCluster = featClusters{n};
                    s = length(clusters);
                    temp_clusters = clusters;
                    if(s~=0)
                        temp = clusters{s};
                        while(min(temp{5}) > min(featCluster{5}))
                            s = s-1;
                            if(s>0)
                                temp = clusters{s};
                            else
                                break;
                            end
                        end
                        
                    end
                    clusters{s+1} = featCluster;
                    for t=s+1:length(temp_clusters)
                        clusters{t+1} = temp_clusters{t};
                    end                        
                end
            end
        end
      
      
      correctionVector = [0 0];
      lastLandmark = {[0 0],timeSlots(1)};
      for p =1:length(clusters)              
            found = 0;
            featCluster = clusters{p};
            feature = featCluster{1};
            centroid = featCluster{2};
            numPoints = featCluster{3};
            location = featCluster{4};
            clusterTime = featCluster{5};
            firstTime = min(clusterTime);
            %6: the first time stamp, 
            %7: feature data
            %8: number of clusters combined to get this one
            %9 : time before which last landmark was seen
           % try
            for k=1:size(stableFeat,2)
                if(strcmp(feature,stableFeat{k}))
                    stableClusters = stable{k};
                    min_val = 4; min_cluster = 0;
                    for m =1:size(stableClusters,2)
                        if(mean(mean(pdist2(location,stableClusters{m}{4},'euclidean'))) < min_val) %TODO:nearness in feature space
                            found = 1;
                            min_val = mean(mean(pdist2(location,stableClusters{m}{4},'euclidean')));
                            min_cluster = m;
                            %Combine
                        end
                    end

                    if(found && i~=1)
                        diff = (stableClusters{min_cluster}{2} - centroid);                 %Localization
                       
                        newPath = correctLocation(newPath, diff, lastLandmark,firstTime,timeSlots,centroid);
                        lastLandmark =  {stableClusters{min_cluster}{2}, firstTime};
                        
                        result = combineClusters(featCluster,stableClusters{min_cluster},correctionVector);     %Stabilization
                        disp(stableFeat{k});
                        stable{k}{min_cluster} = result;
                        
                        diff = (stable{k}{min_cluster}{2} - centroid);
                        correctionVector = correctionVector + diff;
                    else
                        k_stable = stable{k};
                        featCluster{8} = 1;
                        k_stable{end+1} = featCluster;
                        stable{k} = k_stable;
                        found = 1;
                    end
                    break;
                end
            end
            %catch
             %   disp('error');
           % end

            if(~found)
                stableFeat{end+1} = feature;
                featCluster{8} = 1;
                stable{end+1} = {featCluster};
            end
       end

end