function [count num] = countStable()
    warning('off','all');
    count = [];     %count(i,j) -- ith feature combination for jth goodness measure
    num = [0 0 0];
   
    cdf = [];
    for i=1:3
        for j=1:3
            count(i,j) = 0;
        end
    end
    for device = {'Galaxy_S3', 'Galaxy_S2'}
       for place = {'TechMarket'}
            for person = {'Ananth', 'Suman', 'Sourav', 'Swadhin'}
                for time = {'Day', 'Night'}
%                     device = 'Galaxy_S2'; place = 'TechMarket'; person = 'Swadhin'; time = 'Night';
%                     dir_path = strcat('/home/swadhin/Landmark/data/Landmarker_Data/',device,'/',place,'/',person,'/',time,'/');
                    dir_path = strcat('../data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');

                     
%                     for j=1:4
%                         count(j) = 0;
%                     end

                for j = [3]
                    x = load(strcat(dir_path,'/DR_stable_',num2str(j)));

                    if(size(x.stable) ==0)
                        disp(dir_path);
                        %continue;
                    end


                    for confidence = 4
                        cl= x.stable;
                        for f=1:size(cl,2)
                            featCluster = cl{f};
                            for n=1:size(featCluster,2)
                                cluster = featCluster{n};
                                feature = cluster{1};
                                factor = cluster{8};
                                i = length(find(feature==' '))/2+1;

                                if(factor>=confidence)
                                    count(i,round(j/3)+1) = count(i,round(j/3)+1) + 1;
                                end

                            end
                        end                 
                    end

                end

                    %cdf = [cdf;count];
                    
                    
                end
            end
        end
    end
%     
%     figure;
%     hold on;
%   for i=1:4
%     cdfplot(cdf(:,i));
%   end
end
