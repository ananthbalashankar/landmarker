function [avg avg_c avgStable  num] = changePerson(threshold,confidence,pl)
    warning('off','all');
    count = [];     %count(i,factor) -- ith feature combination for appearing in factor number of samples
    clusterCount = [];
    num = 0;
    
    ratio = [];
    avgStable = [];
    avg_1=[];
    avg_2=[];
    avg_3=[];
    avg_4=[];
    
    avg_c4=[];
    avg_c3=[];
    avg_c2=[];
    avg_c1=[];
    
    
    for device = {'Galaxy_S3','Galaxy_S2'}
       for place = {pl}
           for time = {'Day','Night'}
               for d=1:4
                    clusterCount(d) = 0;
               end
                count = [];
                d = 0;
                stable = {};
                stableFeat = {};
                for person = {'Ananth','Suman', 'Sourav','Swadhin'}
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
                            %if(factor>=3)
                            try
                                count(d,factor) = count(d,factor) + 1;
                            catch
                                count(d,factor) = 1;
                            end
                            %end
                            clusterCount(d) = clusterCount(d) +1;
                            
                        end
                    end
                    [stable stableFeat] = analyzeStability(cl,stable,stableFeat,confidence); 
                end
               if(count(1)~=0)
                    %ratio(end+1) = [1 count(2)/count(1) count(3)/count(1) count(4)/count(1)];
                    avg_1(end+1) = sum(count(1,confidence:end));
                    avg_2(end+1) = sum(count(2,confidence:end));
                    avg_3(end+1) = sum(count(3,confidence:end));
                    avg_4(end+1) = sum(count(4,confidence:end));
                    avg_c1(end+1) = clusterCount(1);
                    avg_c2(end+1) = clusterCount(2);
                    avg_c3(end+1) = clusterCount(3);
                    avg_c4(end+1) = clusterCount(4);
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
               end
                
            end
        end
    end
    
    avg = [avg_1; avg_2; avg_3; avg_4];
    avg_c = [avg_c1; avg_c2; avg_c3; avg_c4];
    
end
