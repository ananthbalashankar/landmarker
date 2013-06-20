function plotstable()
   
   cstring = 'rgbymck';

%    for device = {'Galaxy_S3', 'Galaxy_S2'}
%        for place = {'TechMarket','CS_dep'}
%             for person = {'Ananth', 'Suman', 'Sourav', 'Swadhin'}
%                 for time = {'Day', 'Night'}
                    device = 'Galaxy_S2'; place = 'CS_dep'; person = 'Swadhin'; time = 'Night';
                    dir_path = strcat('../data/Landmarker_Data/',device,'/',place,'/',person,'/',time,'/');
                    %dir_path = strcat('../data/Landmarker_Data/',device{1},'/',place{1},'/',person{1},'/',time{1},'/');
                    
                    x = load(strcat(dir_path,'/DR_stable_3'));
                    if(size(x.stable) ==0)
                        disp(dir_path);
                        %continue;
                    end

                    y = load(strcat(dir_path,'/stableLocation_3'));
                    xpos = y.newLocation(:,1);
                    ypos = y.newLocation(:,2);
                    
                    
                    %h=dialog ( 'visible', 'off', 'windowstyle', 'normal' );
                    %ax=axes('parent', h, 'nextplot', 'add' );
                    plot(xpos,ypos,'-');
                    cl= x.stable;
                    clusterNum = 0;
                    for f=1:size(cl,2)
                        featCluster = cl{f};
                        
                       
                        
                        hold on;
                        for n=1:size(featCluster,2)
                            cluster = featCluster{n};
                            feature = cluster{1};
                            factor = cluster{8};
                            loc = cluster{4};
                            xaxis = loc(:,1);
                            yaxis = loc(:,2);
                            if(factor>=3)
                                feature
                                clusterNum
                                cstring(mod(clusterNum,7)+1)
                                plot(xaxis,yaxis,strcat(cstring(mod(clusterNum,7)+1),'+'));
                                %saveas ( ax, strcat(dir_path,'/_3'), 'fig' );
                                clusterNum = clusterNum +1;
                            end
                        end
                    end
%                                          
                    %[stable stableFeat] = getStableClusters(clusters);
%                 end
%             end
%         end
%    end
end
