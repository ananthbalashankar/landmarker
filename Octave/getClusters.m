function [results threshold areas] = getClusters( foldername )

results = {};
results_1 = {};
results_2 = {};
results_3 = {};
filenames = dir(foldername);
files = {};
threshold = {};
areas = {};
close all;
% data and files stored in this order
% _0-acc--1
% _1-magnetic---2
% _10-orientation--3  --- not needed for clustering, but needed for loc
% _11-gravity---4
% _2-gyro---5
% _7-rot---6        --- not raw
% _8-lin acc---7    --- not raw
% _9- sound----8
% _4 - light ---- 9
% wifi --- 10
% gsm --- 11

for j = [0 1 10 11 2 7 8 9 4]
    for(i=1:length(filenames))
        match=regexpi(filenames(i).name,strcat('._',num2str(j),'\.txt'));
        if(isempty(match) == false)
            files{end+1} = strcat(foldername,'/',filenames(i).name);
        end
    end
end
files{10} = strcat(foldername,'/','wifiScan_mod.txt');

files{11} = strcat(foldername,'/','gsmCnriResults.txt');

%Get Location
files{7}
linacc = importdata(files{7},' ',1);
ori = importdata(files{3},' ',1);
gyro = importdata(files{5},' ',1);
[xpos ypos LocTime]= getLocation(linacc.data,ori.data,gyro.data,foldername);
save(strcat(foldername,'/location'),'xpos','ypos');

%% Plot on Google Maps
%lat1 = 22.317778;
%lon1 = 87.309101;
%lat = [lat1];
%lon = [lon1];
%R = 6378100;
%for i=1:length(xpos)-1f
%    brng = bearing(i);
%    d = dist(i);
%    lat2 = asind(sind(lat1)*cos(d/R) + cosd(lat1)*sin(d/R)*cos(brng) );
%    lon2 = lon1 + (atan2(sin(brng)*sin(d/R)*cosd(lat1), cos(d/R)-sind(lat1)*sind(lat2))*180/pi);
%    lat1 = lat2;
%    lon1 = lon2;
%    lat = [lat,lat1];
%    lon = [lon,lon1];
%end

%cd googleearth\;
%kmlstr = ge_plot(lon,lat,'lineColor','FF0000FF');
%disp(kmlstr);
%cd ..;
%save('plot.kml',kmlstr);
%lat = [48.8708 51.5188 41.9260 40.4312 52.523 37.982];
%lon = [2.4131 -0.1300 12.4951 -3.6788 13.415 23.715];
%figure(2);
%hold on;
%plot(lon,lat,'.r','MarkerSize',2)
%plot_google_map('maptype','roadmap','APIKey','AIzaSyDJPYpcPX9oN4pBMhiJHewszAy9-fC-8r4')

%plot_google_map('maptype','roadmap','APIKey','AIzaSyDJPYpcPX9oN4pBMhiJHewszAy9-fC-8r4')
%plot(lon1,lat1,'.r','MarkerSize',20)

%
startTime = inf; stopTime = 0;

wifi = 0; gsm = 0;
%Getting data from files
for i=1:10    %no wifi, no gsm
    if(i==8)%Sound data
        %files{8}
        %fid = fopen(files{8});
        %temp = textscan(fid,'%s %s %s',1);
%        y = textscan(fid,'%s,%s,%s','headerlines',1);
%        h = [];
%        h(:,1)= y{1,1}(:);
%        h(1,1)
%        h(:,2) = y{1,2}(:);
%        g=[];
%        for v=1:length(h(:,1))
%            if(strcmp(y{1,3}(v),'-Infinity'))
%                g(end + 1) = -1;
%            else
%                g(end + 1) = str2double(y{1,3}(v));
%            end
%            startTime = min(startTime,h(v,1));
%            stopTime = max(startTime,h(v,1));
%        end
%        x = [h,g'];
%        size(x)
    elseif(i==10)
%        x = importdata(files{i},' ',0);
	fid = fopen(files{i});
	x = textscan(fid,'%s %s %s %d %d');
	fclose(fid);
	taxis =[];ssidaxis = {}; rssiaxis = {};
	k=1; prev = 0; ssids={}; rssis = {};

	for j=1:size(x{1},1)
		t = str2double(x{1}(j){1});
		ssid = x{3}(j){1};
		rssi = x{4}(j);
		if((t~=prev || j==size(x{1},1)) && j~=1)
		    taxis(k) = prev;
		    ssidaxis{k} = ssids;
		    rssiaxis{k} = rssis;
		    k=k+1;
		    ssids={}; rssis = {};     
		end
		found = 0;
		for m=1:size(ssids,2)
		    if(strcmp(ssids{m},ssid)==1)
			rssis{m} = max(rssis{m},rssi);
			found = 1;
			break;
		    end
		end
		if(found==0)
		    ssids{end+1} = ssid;
		    rssis{end+1} = rssi;
		end
		prev = t;
	end

	Ndata{i} = {ssidaxis, rssiaxis, taxis'};
	startTime = min(startTime,min(taxis));
	stopTime = max(stopTime,max(taxis));
        wifi =1;
    elseif(i==11)
        y = importdata(files{i});
        x = [];
        k=1;
        for g =5:length(y)
            gsm_t = textscan(y{g},'%d64 %d %s');
            x(k,1) = gsm_t{1};
            x(k,2) = gsm_t{2};
            k=k+1;
        end
    else
        x = importdata(files{i},' ',1);
    end

    if(i==11)
        if(~isempty(x))
            startTime = min(startTime,min(x(:,1)));
           stopTime = max(stopTime,max(x(:,1)));
        end
    else if(i~=10 && i~=8)
       startTime = min(startTime,min(x.data(:,1)));
       stopTime = max(stopTime,max(x.data(:,1)));
        end
    end

    if(i==9)        % light
        taxis = x.data(:,1);
        xaxis =x.data(:,3);
        Ndata{i} = horzcat(xaxis,taxis);
   elseif(i==11)  %%gsm
       if(~isempty(x))
        taxis = x(:,1);
        xaxis =x(:,2);
        Ndata{i} = horzcat(xaxis,taxis);
        gsm = wifi+1;
       end
    elseif(i~=10)
        taxis = x.data(:,1);
        xaxis =x.data(:,3);
        yaxis = x.data(:,4);
        zaxis = x.data(:,5);
        Ndata{i} = horzcat(xaxis,yaxis,zaxis,taxis);       %actualTime./10^9,sensx,sensy,
    end
end

%



%Getting Features
featData = [];

%Make constant sample rate -- extrapolate if necessary
timeSteps = ceil((stopTime - startTime)/(2*10^7));         %%50Hz

timeSlots = [startTime:2*10^7:startTime+(timeSteps*2*10^7)];
LocTime = [0;LocTime];
xpos = interp1(LocTime,xpos',timeSlots,'linear','extrap');
ypos = interp1(LocTime,ypos',timeSlots,'linear','extrap');

% if(wifi~=0)
% xposW = interp1(LocTime,xpos',Ndata{10}(:,2),'linear','extrap');
% yposW = interp1(LocTime,ypos',Ndata{10}(:,2),'linear','extrap');
% end
% 
% if(gsm~=0)
% xposG = interp1(LocTime,xpos',Ndata{11}(:,2),'linear','extrap');
% yposG = interp1(LocTime,ypos',Ndata{11}(:,2),'linear','extrap');
% end
%try

    clusterWifi(Ndata{10},xpos,ypos,timeSlots,foldername);
%catch
%     cd ~\mycode;   %continue--- less wifi data
%end

for i=1:7
    featData = horzcat(featData,interp1(Ndata{i}(:,4),Ndata{i}(:,[1 2 3]),timeSlots,'linear','extrap'));
end 

light = interp1(Ndata{8}(:,2),Ndata{8}(:,1),timeSlots,'linear','extrap');
featData = horzcat(featData,light');
featData = horzcat(featData,interp1(Ndata{9}(:,2),Ndata{9}(:,1),timeSlots,'linear','extrap')');
% 
% if(wifi~=0)
% featData = [featData Ndata{10}(:,1)];
% end
% if(gsm~=0)
% featData = [featData Ndata{10}(:,1)];
% end

%%%Noise reduction
featData = medfilt1(featData,11);
f_sample = 50;
f_cutoff = 20;
f_norm = f_cutoff/(f_sample/2);
[b1 a1]= butter(3,f_norm,'low');
featData = filtfilt(b1,a1,featData);

featData(:,[7 8 9])=[];     %orientation not needed
featData(:,[13 14])=[];     %rotation matrix x,y not needed
featData = horzcat(featData,[0;diff(featData(:,5))]);   %difference of mag-y

newfeat = featData;
featData = [];

featData = horzcat(featData,zscore(filter(1/10*ones(1, 10), 1, sum(abs(newfeat(:,[1 2 3]))')')));     %mod(acc)
featData = horzcat(featData,zscore(filter(1/10*ones(1, 10), 1, sum(abs(newfeat(:,[4 5 6]))')')));     %mod(mag)
featData = horzcat(featData, newfeat(:,9));                                         %gyro(z)
featData = horzcat(featData, newfeat(:,13));                                         %rotation matrix
%SMA
linacc = newfeat(:,[14 15 16]);

SMA = zscore(filter(1/10*ones(1, 10), 1, sum(abs(linacc)')'));
featData = horzcat(featData, SMA);
featData = horzcat(featData, newfeat(:,17));                                         %sound
featData = horzcat(featData, newfeat(:,18));                                         %light
featData = horzcat(featData, newfeat(:,19));                                         %derivative of mag-y
% if(wifi~=0)                                                                         %wifi
%  featData = horzcat(featData, newfeat(:,wifi)); 
% end
% if(gsm~=0)
%  featData = horzcat(featData, newfeat(:,gsm)); 
% end

%
%%%% Features 1-21: x 3: normalized,mean,variance
% 1. acc -x
% 2. acc -y
% 3. acc -z
% 4. mag -x
% 5. mag -y
% 6. mag -z
% 7. grav -x
% 8. grav -y
% 9. grav -z
% 10. gyro -x
% 11. gyro -y
% 12. gyro -z
% 13. rotation matrix -z
% 14. lin acc -x
% 15. lin acc -y
% 16. lin acc -z
% 17. sound
% 18. light
% 19. wifi-rssi
% 20. gsm-signal strength
% 21. derivative of mag -y
% 
% 64. SMA
%%%%

%
%%%Normalized data
if(isempty(featData))
    return
end
featData=zscore(featData);
% 
%moving average
for i=1:8
    x = zscore(filter(1/10*ones(1, 10), 1, featData(:,i)));
    featData = horzcat(featData,x);
end

%moving variance
for i=1:8
    a= featData(:,i)';
    x = zscore(movingstd(a,10,'backward')'.^2);
    featData = horzcat(featData,x);
end


%

 feat = 1:58;
 areas = {};
 threshold = {};
 areas_1 = {};
 areas_2 = {};
 areas_3 = {};
%Single feature clustering
for i=1:size(featData,2)
    result = {};
    goodness = {};
    areas = {};
    [result goodness areas] = getLocationClusters(featData(:,i),xpos,ypos,i,foldername,timeSlots);
    threshold{i} = goodness; 
    if(~isempty(result{1}))
        results_1{end+1} = result{1};
        areas_1{i} = areas{1}; 
    end
    if(~isempty(result{2}))
        results_2{end+1} = result{2};
        areas_2{i} = areas{2};
    end
    if(~isempty(result{3}))
        results_3{end+1} = result{3};
        areas_3{i} = areas{3};
    end
end

%% Two feature clustering

%    for i=1:8
%        for j=i+1:8
%            cluster_data = [featData(:,i),featData(:,j)];
%            [result goodness areas] = getLocationClusters(cluster_data,xpos,ypos,[i j],foldername,timeSlots);
%            threshold{i,j} = goodness;
%            if(~isempty(result{1}))
%                results_1{end+1} = result{1};
%                areas_1{i,j} = areas{1};
%            end
%            if(~isempty(result{2}))
%                results_2{end+1} = result{2};
%                areas_2{i,j} = areas{2};
%            end
%            if(~isempty(result{3}))
%                results_3{end+1} = result{3};
%                areas_3{i,j} = areas{3};
%            end
%        end
%    end
%    
%% Three feature clustering
%   for i=1:8
%       for j=i+1:8
%           for k=j+1:8
%               cluster_data = [featData(:,i),featData(:,j),featData(:,k)];
%               [result goodness areas] = getLocationClusters(cluster_data,xpos,ypos,[i j k],foldername,timeSlots);
%               threshold{i,j,k} = goodness;
%               if(~isempty(result{1}))
%                    results_1{end+1} = result{1};
%                    areas_1{i,j,k} = areas{1};
%                end
%                if(~isempty(result{2}))
%                    results_2{end+1} = result{2};
%                    areas_2{i,j,k} = areas{2};
%                end
%                if(~isempty(result{3}))
%                    results_3{end+1} = result{3};
%                    areas_3{i,j,k} = areas{3};
%                end
%           end
%       end
%   end

results = { results_1 results_2 results_3};
areas = {areas_1 areas_2 areas_3};

end



