function [count num] = countClusters()
    warning('off','all');
    count = [];     %count(i,j) -- ith feature combination for jth goodness measure
    num = [];
    for i=1:3
        for j=1:3
            count(i,j) = 0;
            num(i,j) = 0;
        end
    end
    for device = {'Galaxy_S3', 'Galaxy_S2'}
       for place = {'CS_dep'}
            for person = {'Ananth', 'Suman', 'Sourav', 'Swadhin'}
                for time = {'Day', 'Night'}
                    device = 'Galaxy_S2'; place = 'TechMarket'; person = 'Swadhin'; time = 'Night';
                    dir_path = strcat('../data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');
                    filenames = dir(dir_path);
                    files = {};
                    for i=1:length(filenames)
                        match=regexpi(filenames(i).name,'SensoSaur_.');
                        if(isempty(match) == false)
                            files{end+1} = strcat(dir_path,filenames(i).name);
                        end
                    end
                    
                    for file = files
                        file = file{1};
                        x = load(strcat(file,'/clusters_new'));
                        if(size(x.cluster) ==0)
                            disp(file);
                            continue;
                        end
                        
                        for i=1:3
                            for j=1:3
                                num(i,j) = num(i,j)+1;
                            end
                        end
                        for j=1:3
                            try
                            cl = x.cluster{j};
                            catch
                                disp('error');
                            end
                            for f=1:size(cl,2)
                                featCluster = cl{f};
                                for n=1:size(featCluster,2)
                                    cluster = featCluster{n};
                                    feature = cluster{1};
                                    i = length(find(feature==' '))/2+1;
                                    try
                                    count(i,j) = count(i,j) + 1;
                                    catch
                                    end
                                end
                            end
                        end
                     end                    
                    %[stable stableFeat] = getStableClusters(clusters);
                end
            end
        end
    end
    
    for i=1:3
        for j=1:3
            count(i,j)= count(i,j)/num(i,j);
        end
    end
end
