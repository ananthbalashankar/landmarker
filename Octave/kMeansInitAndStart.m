function [ initialSeeds,optK ] = kMeansInitAndStart( data , noSamples , max_cluster )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%Creating random sample subsets from dataset

dataLen = length(data(:,1));
sampVect = randperm(dataLen);
%sampVect

sSize = round(dataLen/noSamples);

sampVectCont = [];
sampVectContL = [];

for(i=1:sSize:dataLen)
    if( i+sSize >= dataLen)
        sampVectContL =sampVect(i:dataLen)';
        break
    end
    
    sampVectCont = [sampVectCont;sampVect(i:i+sSize-1)']; 
end

%sampVectCont

[ row, col ] = size(sampVectCont);

ctrsSamples = [];
%disp('row');
%row;

%Calculating centres by doing kmeansmod in each sample subset to get k clusters from each sample 
for i=1:row
    tempData = [];
    
    for j=1:col
        %sampVectCont(i,j)
        tempData = [tempData;data(sampVectCont(i,j),:)];
    end
    
    ctrs =[];
    %try
        [idx,ctrs,sumd] = kmeans(tempData,min(size(tempData,1),max_cluster));%,'MaxIter',2000);
       
    %catch
        %disp('Here');
        %[idx,ctrs,sumd] = kmeans(tempData,min(size(tempData,1),max_cluster),'emptyaction','singleton','MaxIter',2000);
        %[idx,ctrs,sumd] = kmeansMod(tempData,min(size(tempData,1),max_cluster),ctrs);
    %end
    
    
    ctrsSamples = [ctrsSamples;ctrs];
    
    clear idx
    clear ctrs
    
end

%for the last vector
tempData = [];

for(j=1:size(sampVectContL,1))
    tempData = [tempData;data(sampVectContL(j,1),:)];
end
tmpSize = size(tempData);
if(tmpSize(1) > max_cluster)
    ctrs = [];
%    try
        [idx,ctrs,sumd] = kmeans(tempData,min(size(tempData,1),max_cluster));
%    catch 
%        % disp('There');
%        [idx,ctrs,sumd] = kmeans(tempData,min(size(tempData,1),max_cluster),'emptyaction','singleton','MaxIter',2000);
%        [idx,ctrs,sumd] = kmeansMod(tempData,min(size(tempData,1),max_cluster),ctrs);
%    end
    
    ctrsSamples = [ctrsSamples;ctrs];
end
clear idx
clear ctrs

% calculating cluster centers from thes subset centers using kmeans
FMS = [];
DistortSums = [];

size_ctrs = size(ctrsSamples,1);
j = 1;
for(i=1:noSamples)
    
    %[idx,ctrs,sumd] = kmeans(ctrsSamples,max_cluster,'start',ctrsSamples(j:j+max_cluster-1,:));
    %disp(ctrsSamples(randsample(size_ctrs,max_cluster),:));
    try
        [idx,ctrs,sumd] = kmeans(ctrsSamples,min(size(ctrsSamples,1),max_cluster),'start',ctrsSamples(randperm(size_ctrs,max_cluster),:));
    catch 
      	lasterr = lasterror();
        if(strcmp(lasterr.message,"randperm: M must be less than or equal to N")==0)
					msg = lasterr;
				end
					
        if(size_ctrs<max_cluster)
            initialSeeds = [];
            optK = -1;
            return;
        end
        [idx,ctrs,sumd] = kmeansMod(ctrsSamples,min(size(ctrsSamples,1),max_cluster),ctrsSamples(randperm(size_ctrs,max_cluster),:));
    end
    FMS = [ FMS;ctrs ];
    DistortSums = [DistortSums;sum(sumd)];
    j=j+max_cluster;
    
    clear idx;
    clear ctrs;
    clear sumd;
end

%Find the cluster set with minimum sum

 indx = find(min(DistortSums));
 
 strtIndx = (indx-1)*max_cluster+1;
 
 %calculating INITIAL SEEDS (Method 5, BF98 )
 initialSeeds = ctrsSamples(strtIndx:strtIndx+max_cluster-1,:);
 
 optK = optKinKmeans(data,max_cluster,initialSeeds);
 
 %[idx,ctrs] = kmeans(data,optK,'start',initialSeeds(1:optK,:))
 
%sampVectCont
%sampVectContL

end

