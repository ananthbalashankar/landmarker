function [stable stableFeat newLocation] = stabilize()
    warning('off','all');
    clusters = {};
    err = 0;
    err_count = 0;
%     for device = {'Galaxy_S2','Galaxy_S3'}
%         for place = {'CS_dep','TechMarket'}
%             for person = {'Ananth', 'Suman', 'Sourav', 'Swadhin'}
%                 for time = {'Day', 'Night'}
                    device = 'Galaxy_S2'; place = 'CS_Dep'; person = 'Swadhin'; time = 'Night';
                    dir_path = strcat('../data/Landmarker_Data/',device,'/',place,'/',person,'/',time,'/');
                    %dir_path = strcat('../data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');
                    filenames = dir(dir_path);
                    files = {};
                    %%%%change initial Landmarks here
                    s = load(strcat('../data/Landmarker_Data/','Galaxy_S3','/',place,'/',person,'/',time,'/DR_stable_3'));
                    stable = s.stable;
                    stableFeat = s.stableFeat;
                    for i=1:length(filenames)
                        match=regexpi(filenames(i).name,'SensoSaur_.');
                        if(isempty(match) == false)
                            files{end+1} = strcat(dir_path,filenames(i).name);
                            disp(files{end});
                        end
                    end
                    
                    for file = files
                        file = file{1};
                        x = load(strcat(file,'/clusters_new'));
                        loc = load(strcat(file,'/location'));
                        location = [loc.xpos' loc.ypos'];
                        timeSlots = loc.timeSlots;
%                         err = err + sqrt(location(end,1)^2 + location(end,2)^2);
%                         err_count = err_count + 1;
                        if(~isempty(x.cluster))
                            cluster = x.cluster{2};
                            clusters{end+1} = cluster;
                        end
                        
                        [stable stableFeat newLocation] = getStableClusters(cluster,location,timeSlots,stable,stableFeat);                        %calculate stable clusters
                        save(strcat(file,'/newLocation'),'newLocation','timeSlots');
                    end                    
                     
                    %save(strcat(dir_path,'stableLocation_3'),'newLocation');
                    %save(strcat(dir_path,'DR_stable_3'),'stable','stableFeat');
%                 end
%             end
%         end
%     end
end
