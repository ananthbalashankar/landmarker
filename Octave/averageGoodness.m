function [area] = averageGoodness()
    warning('off','all');
         
    area = {};
    
    %close all;
    for device = {'Galaxy_S3'}
       for place = {'TechMarket'}
            for person = {'Ananth', 'Suman', 'Sourav', 'Swadhin'}
                for time = {'Day', 'Night'}
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
                    goodness = load(strcat(file,'/goodness'));
                    areas = load(strcat(file,'/areas'));
                    areas = areas.areas;
                    goodness = goodness.goodness;
                    
                    A = areas{2};
                    
                   
                     for j=1:size(A,2)
                        
                        try
                            arr = A(j);
                            arr = arr{1};
                            prev = area{j};
                            prev = [ prev arr];
                            area{j} = prev;
                        catch
                            area{j} = arr;
                        end
                     end
                     try
                         wifi = load(strcat(file,'/wifi'));
                     catch
                        continue;    
                     end
                     try
                         wifi = wifi.results;
                         arr = [];
                         k = 1;
                         for j=1:length(wifi)
                             if(wifi{j}{1} >= 5)
                                 arr(k) = wifi{j}{3};
                                 k = k+1;
                             end
                         end
                         prev = area{9};
                         area{9} = [prev arr];
                     catch
                         area{9} = arr;
                     end
                     
                            

                   

                    %end
                end
                end
            end
       end
    end
    figure;
    hold on;
    for i=1:length(area)
       cdfplot(area{i});
    end
    legend('mod(acc)','mod(mag)','gyro-z','rotation matrix-z','SMA','sound','light','derivative of mag-y','wifi','gsm');
    axis([0 50 0 0.9]);
end
