function clusterWifi(data,xpos,ypos,timeSlots,foldername)
fid = fopen(strcat(foldername,'/wifi.csv'),'w');
fclose(fid);
cd MatEx1.5/
[Medoids,clusvector,DIST] = KMedoidshort(data,2,1,0);
cd ..
time = data{3};
time = time';
maxk = 5;
%h=dialog ( 'visible', 'off', 'windowstyle', 'normal' );
%ax=axes('parent', h, 'nextplot', 'add' );
cstring = 'rgbymck';

results = {};

for i=1:size(Medoids,2)
    k=1;
    cluster_data=[];
    mTime = time(clusvector==i);
    for j=1:size(mTime,2)
        while(k<size(timeSlots,2))
            if(mTime(j) < timeSlots(k))
                cluster_data(j,1) = xpos(k);
                cluster_data(j,2) = ypos(k);
                break;
            end
            k=k+1;
        end    
    end
    if(size(cluster_data,1) >2)
        [initialseeds,optk]=kMeansInitAndStart(cluster_data,10,min(maxk,size(cluster_data,1)));
        if(optk==-1)
            continue;
        else
            [Lidx,Lcentroid] = kmeansMod(cluster_data,optk,initialseeds);
            Lsumd = getClusterDistance(cluster_data,Lidx,Lcentroid);
            clusterNum = 1;
           for n=1:optk
                numOfPoints = sum(Lidx==n);
                %if(Lsumd(n)/numOfPoints < 5)        %%%within 5 m from the centroid for each cluster
                    if(clusterNum==1)
                        ax = plot(xpos,ypos,'-');
												hold on;
                    end
                    fid = fopen(strcat(foldername,'/wifi.csv'),'a');
                    %clusters, location cluster number ,feature cluster num, num of points in the location cluster,x,y of the centroid, intra-cluster avg distance. 
                    %fprintf(fid,'%s,%d,%d,%d,%d,%f,%f,%f\n','wifi',clusterNum,j,n,numOfPoints,Lcentroid(n,1),Lcentroid(n,2),Lsumd(n)/numOfPoints);
                    %fclose(fid);
                    
                   
                    
                    xaxis = cluster_data(:,1);
                    yaxis = cluster_data(:,2);
                    results{end+1} = {numOfPoints, [Lcentroid(n,1) Lcentroid(n,2)], Lsumd(n)/numOfPoints, [xaxis(Lidx==n) yaxis(Lidx==n)]};
                    hold on;
		                ax = plot(xaxis(Lidx==n),yaxis(Lidx==n),strcat(cstring(mod(clusterNum,7)+1),'+'));
                    saveas ( ax, strcat(foldername,'/wifi'), 'png' );
                    %legend(ax,strcat(num2str(features),'/',num2str(j),'/',num2str(n)));
                    clusterNum = clusterNum + 1;
                    %axis([-5 18 -20 5]);
               % end
           end
        end
    end
end

save(strcat(foldername,'/wifi'),'results');
end
