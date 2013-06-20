function [errors] = calculateError()
errors = [];
    for device = {'Galaxy_S2'}
       for place = {'TechMarket'}
            for person = {'Swadhin'}
                for time = {'Night'}
%                     device = 'Galaxy_S2'; place = 'TechMarket'; person = 'Swadhin'; time = 'Night';
%                     dir_path = strcat('/home/swadhin/Landmark/data/Landmarker_Data/',device,'/',place,'/',person,'/',time,'/');
                    dir_path = strcat('../data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');
                filenames = dir(dir_path);
                files = {};
                stable = {};
                stableFeat = {};
                for i=1:length(filenames)
                    match=regexpi(filenames(i).name,'SensoSaur_.');
                    if(isempty(match) == false)
                        files{end+1} = strcat(dir_path,filenames(i).name);
                        %disp(files{end});
                    end
                end

                for file = files
                    file = file{1};
                    %try
%                     location= load(strcat(file,'/location'));
%                     xpos = location.xpos;
%                     ypos = location.ypos;
%                     time = location.timeSlots;
%                     err = sqrt((xpos(end)-xpos(1))^2 + (ypos(end)-ypos(1))^2);

                  location = load(strcat(file,'/newLocation'));
                  xpos = location.newLocation(:,1);
                  ypos = location.newLocation(:,2);
                  err = sqrt((xpos(end)-xpos(1))^2 + (ypos(end)-ypos(1))^2);
                    errors = [errors err]; 
                end
                end
            end
       end
    end
    cdfplot(errors);
end