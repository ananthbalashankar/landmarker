function [count stable num] = countFeatures(threshold)
    warning('off','all');
    close all;
        %count(i,factor) -- ith feature combination for appearing in factor number of samples
    stable = {'4  7','3','5','2','7','3  4','4','2  4','2  4  7','4  5','3  4  7','2  7','1  7','1  6  7','1  4','4  8','2  5','2  3','3  7','2  6  7','6  7','4  6','4  5  7','1','3  6  7','8','2  4  8','4  6  7','2  6  8','6','7  8'};
    for i=1:31
        for d=1:4
           count(d,i) = 0;
        end
    end
    
    stableCount = [];
    for v=1:31
        stableCount(i) = 0;
    end
    num = 0;
    confidence = 3;
    for place={'CS_dep'}
    %for place = {'TechMarket'}
         for person = {'Ananth', 'Suman', 'Sourav', 'Swadhin'} 
             for time = {'Day','Night'} 
                d = 0;
                num = num+1;
                stableClusters = {};
                stableFeat = {};
                 
                    for device = {'Galaxy_S3','Galaxy_S2'}
                    
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
                                feat = 0;
                                if(factor>=confidence)

                                    for s=1:length(stable)
                                        if(strcmp(stable{s},feature))
                                            feat = s;
                                            break;
                                        end
                                    end
                                    if(feat==0)
                                        stable{end+1} = feature;
                                        feat = s+1;
                                        disp(feature);
                                        %disp('error');
                                        stableCount(feat) = 0;
                                        count(d,feat) = 0;
                                    end

                                    count(d,feat) = count(d,feat) + 1;
                                end


                            end
                        end

                        [stableClusters stableFeat] = analyzeStability(cl,stableClusters,stableFeat,confidence); 
                    end
                    
                    numFeatures = size(stableClusters,2);
                     for j=1:numFeatures
                        featClusters = stableClusters{j};
                        if(~isempty(featClusters))
                            for n=1:size(featClusters,2)
                                featCluster = featClusters{n};
                                if(featCluster{8} > 1)
                                    feature = featCluster{1};
                                    for s=1:length(stable)
                                        if(strcmp(stable{s},feature))
                                            feat = s;
                                            break;
                                        end
                                    end
                                    stableCount(feat) = stableCount(feat) + 1;
                                end
                            end
                        end
                     end

                    %avgStable(end+1) = stableCount;
            end
        end
    end
    num
    count = count/num;
    stableCount = stableCount/num;
    
    good1 = count(1,:);
    good1 = good1 >= 0.5;
    good2 = count(2,:);
    good2 = good2 >=0.5;
    good3 = count(3,:);
    good3 = good3 >=0.5;
    good4 = count(4,:);
    good4 = good4 >=0.5;
    
    good = good1 + good2 + good3 + good4;
    good = good >= 1;
    figure;
    bar(count([1 2 3 4],good)');
    legend('S3','S2');
    
    figure;
    count(1,:) = count(1,:) - stableCount;
    count(1,:) = max(0, count(1,:));
    count(2,:) = count(2,:) - stableCount;
    count(2,:) = max(0, count(2,:));
    count(3,:) = count(3,:) - stableCount;
    count(3,:) = max(0, count(3,:));
    count(4,:) = count(4,:) - stableCount;
    count(4,:) = max(0, count(4,:));
    bar([stableCount(good);count([1 2 3 4],good)]','stack');
    legend('stable','S3','S2');
    
    fid = fopen(strcat('final-figs/features-device.txt'),'w');
    
    for i=1:length(stable)
        if(good(i)==1)
            fprintf(fid,stable{i});
            fprintf(fid,'\n');
        end
    end
    fclose(fid);
    
    
    
end
