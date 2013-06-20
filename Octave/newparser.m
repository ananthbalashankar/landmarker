function  newparser()
    warning('off','all');
%     for device = {'Galaxy_S3', 'Galaxy_S2'}
%         for place = {'CS_dep','TechMarket'}
%             for person = {'Ananth', 'Suman', 'Sourav', 'Swadhin'}
%                 for time = {'Day', 'Night'}
                    %dir_path = strcat('/home/swadhin/Landmark/data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');
                    device = 'Galaxy_S2'; place = 'CS_dep'; person = 'Sourav'; time = 'Night';                
                    dir_path = strcat('/home/swadhin/Landmark/data/Landmarker_Data/',device,'/',place,'/',person,'/',time,'/');
                    filenames = dir(dir_path);
                    files = {};
                    for i=1:length(filenames)
                        match=regexpi(filenames(i).name,'SensoSaur_.');
                        if(isempty(match) == false)
                            files{end+1} = strcat(dir_path,filenames(i).name);
                            disp(files{end});
                        end
                    end
                    
                    for file = files
                        file = file{1};
                        command = strcat('perl wifi_ap_info_reader.pl "',file,'"');
                        status = dos(command,'-echo');
                        getLocations(file);
                     end                    
%                 end
%             end
%         end
%     end
end
