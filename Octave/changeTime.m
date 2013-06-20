function [ratio avg_1 avg_2 avg_c1 avg_c2 avgStable num] = changeTime(threshold,confidence,pl)
    warning('off','all');
    count = [];     %count(i,factor) -- ith feature combination for appearing in factor number of samples
    clusterCount = [];
    num = 0;
    ratio = [];
    avg_1 = [];
    avg_2 = [];
    avg_c1 = [];
    avg_c2 = [];
    avgStable = [];
    
       for place = {pl}
            for person = {'Ananth','Suman', 'Sourav', 'Swadhin'}
                for device = {'Galaxy_S3', 'Galaxy_S2'}

                    for d=1:2
                        %count(d,) = 0;
                        clusterCount(d) = 0;
                    end
                    d = 0;
                    count =[];
                    stable = {};
                    stableFeat = {};
                    for time = {'Day','Night'}
                        d = d+1;
                        %device = 'Galaxy_S2'; place = 'TechMarket'; person = 'Swadhin'; time = 'Night';
                        dir_path = strcat('../data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');

                        x = load(strcat(dir_path,'/DR_stable_',num2str(threshold)));
                        if(size(x.stable) ==0)
                            disp(dir_path);
                            continue;
                        end



                        cl= x.stable;
                        for f=1:size(cl,2)
                            featCluster = cl{f};
                            for n=1:size(featCluster,2)
                                cluster = featCluster{n};
                                feature = cluster{1};
                                factor = cluster{8};
                                i = length(find(feature==' '))/2+1;
                                %try

                                    %if(factor>=2)
                                    try
                                        count(d,factor) = count(d,factor) + 1;
                                    catch
                                        count(d,factor) = 1;
                                    end
                                    %end
                                    clusterCount(d) = clusterCount(d)+1;  
                                %catch

                                %end
                            end
                        end

                        [stable stableFeat] = analyzeStability(cl,stable,stableFeat,confidence); 
                    end
                   if(~isempty(count))
                       try
                        %ratio(end+1) = sum((count(1,3:end))/sum(count(2,3:end)));
                        avg_1(end+1) = sum(count(1,confidence:end));
                        avg_2(end+1) = sum(count(2,confidence:end));
                        avg_c1(end+1) = clusterCount(1);
                        avg_c2(end+1) = clusterCount(2);
                        stableCount = 0;
                        num = num+1;
                        
                        numFeatures = size(stable,2);
                         for j=1:numFeatures
                            featClusters = stable{j};
                            if(~isempty(featClusters))
                                for n=1:size(featClusters,2)
                                    featCluster = featClusters{n};
                                    if(featCluster{8} > 1)
                                        stableCount = stableCount + 1;
                                    end
                                end
                            end
                         end
                         
                        avgStable(end+1) = stableCount;
                       catch
                           disp(dir_path);
                       end
                   end

                end
            end
       end

    
end
