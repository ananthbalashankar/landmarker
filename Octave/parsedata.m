function  parsedata()
    warning('off','all');
    parseFiles = {};
%    for device = {  'Galaxy_S3'}
%        for place = {'TechMarket','CS_dep'}
%            for person = {'Ananth','Suman','Sourav','Swadhin'}
%                 for time = {'Day', 'Night'}
                    device = 'Galaxy_S3'; place = 'CS_dep'; person = 'Ananth'; time = 'Day';
                    %dir_path = strcat('Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');
                    dir_path = strcat('Landmarker_Data/',device,'/',place,'/',person,'/',time,'/');
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
                            load(strcat(file{1},'/wifi_gsm'));
                            parseFiles{end+1} = file{1};
                        catch
                            parseFiles{end+1} = file{1};
                        end
                    end
%                 end
%            end
%        end
%     end
    

                    
                    index = 0;
                    for file = parseFiles
                        index = index +1;
                        
                            file = file{1};
                            command = strcat('perl wifi_ap_info_reader.pl "',file,'"');
                            status = dos(command,'-echo');
                            for goodness=[0.1 0.3 0.7]
                                string = strcat(file,'/clusters_',num2str(goodness*10),'.csv');
                                fid = fopen(string ,'w');
                                fclose(fid);
                            end
                            [cluster goodness areas] = getClusters(file);
                            save(strcat(file,'/wifi_gsm'),'cluster');
                            save(strcat(file,'/wifi_gsm_area'),'areas');
                            %save(strcat(file,'/clusters_new'),'cluster');
                            %save(strcat(file,'/goodness'),'goodness');
                            %save(strcat(file,'/areas'),'areas');
                     end                    
%                     
%                  end
%             end
%         end
%     end
end
