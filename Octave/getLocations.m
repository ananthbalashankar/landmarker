function getLocations(foldername)
    results = {};
results_1 = {};
results_2 = {};
results_3 = {};
filenames = dir(foldername);
files = {};
close all;
%data and files stored in this order
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
%gsm --- 11

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
[xpos ypos LocTime bearing dist]= getLocation(linacc.data,ori.data,gyro.data,foldername);

%%% Plot on Google Maps
lat1 = 22.317778;
lon1 = 87.309151;
lat = [lat1];
lon = [lon1];
R = 6378100;
for i=1:length(xpos)-1
    brng = bearing(i)+pi-pi/4+pi/6;
    d = dist(i);
    lat2 = asind(sind(lat1)*cos(d/R) + cosd(lat1)*sin(d/R)*cos(brng) );
    lon2 = lon1 + (atan2(sin(brng)*sin(d/R)*cosd(lat1), cos(d/R)-sind(lat1)*sind(lat2))*180/pi);
    lat1 = lat2;
    lon1 = lon2;
    lat = [lat,lat1];
    lon = [lon,lon1];
end

cd googleearth;
kmlstr = ge_plot(lon,lat,'lineColor','FF0000FF');
%disp(kmlstr);
cd ..;
fid = fopen(strcat(foldername,'/plot.kml'),'w');
fprintf(fid, kmlstr);
fclose(fid);

save('plot.kml','kmlstr');
%lat = [48.8708 51.5188 41.9260 40.4312 52.523 37.982];
%lon = [2.4131 -0.1300 12.4951 -3.6788 13.415 23.715];

% plot(lon,lat,'.r','MarkerSize',2)
% plot_google_map('maptype','roadmap')

% plot_google_map('maptype','roadmap','APIKey','AIzaSyDJPYpcPX9oN4pBMhiJHewszAy9-fC-8r4')
% plot(lon1,lat1,'.r','MarkerSize',20)

%%


startTime = inf; stopTime = 0;
%Getting data from files
for i=1:10     %no wifi, no gsm
    if(i==8)%Sound data
        %files{8}
        fid = fopen(files{8});
        temp = textscan(fid,'%s %s %s',1);
        y = textscan(fid,'%d64,%d64,%s');
        h = [];
        h(:,1)= y{1,1}(:);
        %h(1,1)
        h(:,2) = y{1,2}(:);
        g=[];
        for v=1:length(h(:,1))
            if(strcmp(y{1,3}(v),'-Infinity'))
                g(end + 1) = -1;
            else
                g(end + 1) = str2double(y{1,3}(v));
            end
            startTime = min(startTime,h(v,1));
            stopTime = max(startTime,h(v,1));
        end
        x = [h,g'];
        size(x)
    elseif(i==10)
        x = importdata(files{i},' ',0);
   elseif(i==11)
        x = importdata(files{i},' ',1);
    else
        x = importdata(files{i},' ',1);
    end
    if(i~=10 && i~=8)
       startTime = min(startTime,min(x.data(:,1)));
       stopTime = max(stopTime,max(x.data(:,1)));
    end
    if(i==9)        % light
        taxis = x.data(:,1);
        xaxis =x.data(:,3);
        Ndata{i} = horzcat(xaxis,taxis);
    elseif(i==8)    % sound
        taxis = x(:,1);
        xaxis = x(:,3);
        Ndata{i} = horzcat(xaxis,taxis);
    elseif(i==10)  %%wifi
        try
            taxis =[];ssidaxis = {}; rssiaxis = {};
            k=1; prev = 0; ssids={}; rssis = {};
            for j=1:size(x.textdata(:,1),1)
                t = str2num(char(x.textdata(j,1)));
                ssid = char(x.textdata(j,2));
                rssi = x.data(j,1);
                if(t~=prev && j~=1)
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
            startTime = min(startTime,min(taxis));
            stopTime = max(stopTime,max(taxis));
            Ndata{i} = {ssidaxis, rssiaxis, taxis'};
        catch
            continue;
        end
   elseif(i==11)  %%gsm
        taxis = x.data(:,1);
        xaxis =x.data(:,2);
        Ndata{i} = horzcat(xaxis,taxis);
    else
        taxis = x.data(:,1);
        xaxis =x.data(:,3);
        yaxis = x.data(:,4);
        zaxis = x.data(:,5);
        Ndata{i} = horzcat(xaxis,yaxis,zaxis,taxis);       %actualTime./10^9,sensx,sensy,
    end
end

%%



% %Make constant sample rate -- extrapolate if necessary
timeSteps = ceil((stopTime - startTime)/(2*10^7));         %%50Hz

timeSlots = [startTime:2*10^7:startTime+(timeSteps*2*10^7)];
LocTime = [0;LocTime];
xpos = interp1(LocTime,xpos',timeSlots,'linear','extrap');
ypos = interp1(LocTime,ypos',timeSlots,'linear','extrap');

try
    clusterWifi(Ndata{10},xpos,ypos,timeSlots,foldername);
catch
         %continue--- less wifi data
end
save(strcat(foldername,'/location'),'xpos','ypos','timeSlots');

end