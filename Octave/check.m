for device = {  'Galaxy_S3','Galaxy_S2'}
        for place = {'TechMarket','CS_dep'}
            for person = {'Ananth','Suman','Sourav','Swadhin'}
                 for time = {'Day', 'Night'}
                    %device = 'Galaxy_S2'; place = 'TechMarket'; person = 'Sourav'; time = 'Night';
                    dir_path = strcat('../data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');
                    %dir_path = strcat('/home/swadhin/Landmark/data/Landmarker_Data/',device,'/',place,'/',person,'/',time,'/');
                    filenames = dir(dir_path);
                    files = {};
                    for i=1:length(filenames)
                        match=regexpi(filenames(i).name,'SensoSaur_.');
                        if(isempty(match) == false)
                            files{end+1} = strcat(dir_path,filenames(i).name);
                            %disp(files{end});
                        end
                    end
                    
                    for file= files
                        try
                            load(strcat(file{1},'/goodness'));
                        catch
                            disp(file{1});
                        end
                    end
                 end
            end
        end
end
                    