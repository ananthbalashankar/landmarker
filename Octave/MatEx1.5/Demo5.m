% Demo5   Real data analysis

% Set here your dataset (variables in rows)
load ElectricityEurope;
data = ElectricityEurope;
disp('Dataset: 5-years European electricity spot prices')
disp('d=1: France')
disp('d=2: Netherlands')
disp('d=3: Germany')
disp('d=4: UK')
disp('d=5: Spain')
disp('')

% Want a nonparametric unit-Frechet standardization?
stdUnitFrechet = 'no'; % 'yes' or 'no'

% Length of tail dependence
estimatesK='OFF'; % 'ON' or 'OFF'
K=3; % Not used if estimatesK=='ON'

% Total number of profiles
estimatesL='ON'; % 'ON' or 'OFF'
L=3; % Not used if estimatesL=='ON'

% Simulate a process with the fitted extremal behavior ?
simlength = 100;

CM3='M4'; % 'CM3' for the CM3 in Alk.m or 'M4' for a random M4
recoversprofiles='nonequiprobable'; % 'nonequiprobable' (as generated) or 'equiprobable' (patterns only)
extremes='cross-section'; % 'cross-section' or 'profile'
clustering='best'; % 'best', 'exact', 'ward', 'pam' or 'approachedM' (-M or -U)
sortmode='triple'; % 'triple' or 'quadruple' in clustering='approachedM' (-M or -U)
rankreduction='no'; % 'no', 'drop', 'componentwisedrop', 'stereo' or 'svd'
plotprocess='ON'; % 'ON' or 'OFF'
withR='OFF'; % 'ON' or 'OFF'
plotL='ON'; % 'ON' or 'OFF'
MaxRange=15; % in finding L
zeroSS=.2; % in finding L
silmode='max'; % 'threshold' or 'max'
maxSil=.85; % in finding L with silmode='threshold'
graph='mode1'; % 'mode1' 'mode2' 'mode3'
color=['y'; 'r'; 'g'; 'c'; 'm'; 'k'];
viewwindow='OFF'; % final view: 'ON' or 'OFF'
alpha=1;
figindex=1;

C=10; % Range for searching the blocks of extremes (see research paper)
Size=size(data);
D=Size(1); % Number of variables
T=Size(2); % Number of observations

% Number of profile to gather
Q=ceil(T/((2*K-1)*C)); % (Expected value, set a fixed number if you prefer.)

%**** Coherent settings
warning off all;
close all;
if strcmp(estimatesL,'ON'),
extremes='cross-section';
clustering='best';
end
if strcmp(CM3,'CM3'),
graph='mode3';
end

%**** R-link
if strcmp(withR,'ON'),
try
closeR
catch
end
try
openR
evalR('library(evd)')
catch
end
end

% Initial estimator values
K1=0; K2=0; K3=0; K4=0; K5=0; K6=0; K7=0; K8=0; K9=0; K10=0; K11=0; K12=0; K13=0; Kest=0;
Lward=0; Lcentroid=0; LEucli=0; Lkmeans=0; Lpam=0; Lward2=0; Lcentroid2=0; LEucli2=0; Lkmeans2=0; Lpam2=0; Lest=0;

%**** Computation of the process
if strcmp(stdUnitFrechet,'yes'),
y=data2frechet(data);
else
y=data;
end

%**** Estimates K, uses R-link!

if strcmp(estimatesK,'ON'),
if D>1,
maxY=max(y);
threshold=max(maxY)/(C);
invThetaa=1/runsestimator(maxY,1/C,0,'mean');
invThetab=1/runsestimator(y,1/C,0,'mean');
invThetac=1/runsestimator(maxY,1/C,0,'median');
invThetad=1/runsestimator(y,1/C,0,'median');
invThetae=1/runsestimator(maxY,1/C,0,'mode');
invThetaf=1/runsestimator(y,1/C,0,'mode');
try
putRdata('s',maxY);
invThetag=1/evalR(['exi(s, u='  num2str(floor(threshold)) ', r =0, ulow = -Inf)']);
invThetah=1/evalR(['exi(s, u='  num2str(floor(threshold/20)) ', r =0, ulow = -Inf)']);
K11=round(invThetag);
K12=ceil(invThetag);
K13=ceil(invThetah);
catch
warning('R-link off: intervals estimators (K11 K12 K13) not calculed');
end
else
threshold=max(y);
invThetaa=1/runsestimator(y,1/C,0,'mean');
invThetab=invThetaa;
invThetac=1/runsestimator(y,1/C,0,'median');
invThetad=invThetac;
invThetae=1/runsestimator(y,1/C,0,'mode');
invThetaf=invThetae;
try
putRdata('s',y);
invThetag=1/evalR(['exi(s, u='  num2str(floor(threshold)) ', r =0, ulow = -Inf)']);
invThetah=1/evalR(['exi(s, u='  num2str(floor(threshold/20)) ', r =0, ulow = -Inf)']);
K11=round(invThetag);
K12=ceil(invThetag);
K13=ceil(invThetah);
catch
warning('R-link off: intervals estimators (K11 K12 K13) not calculed');
end
end

K1=round(invThetaa);
K2=ceil(invThetaa);
K3=round(invThetab);
K4=ceil(invThetab);
K5=round(invThetac);
K6=ceil(invThetac);
K7=round(invThetad);
K8=ceil(invThetad);
K9=invThetae;
K10=invThetaf;

% choice
if T>=35
Kest=K6;
else
Kest=K8;
end

else
Kest=K;
end

%**** Determines the extremes
isExtreme=extremeblocks(y,Kest,Q,extremes);

%**** MM, table and opttable

MM=max(isExtreme);

table = zeros(MM,D*Kest);
for c=1:MM,
t=1; while isExtreme(1,t)~=c, t=t+1; end
table(c,:)=reshape(y(:,t:t+Kest-1)',1,D*Kest);
table(c,:)=table(c,:)/max(y(:,t));
end

if strcmp(rankreduction,'no'),
opttable=table;

elseif strcmp(rankreduction,'drop'),
if Kest*D>1,
opttable=table(:,1:Kest*D-1);
else
opttable=table;
end

elseif strcmp(rankreduction,'componentwisedrop'),
if Kest>1,
opttable=zeros(MM,(Kest-1)*D);
for d=1:D,
   for c=1:MM,
   opttable(c,1+(d-1)*(Kest-1):d*(Kest-1))=table(c,1+(d-1)*Kest:d*Kest-1)/sum(table(c,1+(d-1)*Kest:d*Kest));
   end
end
else
opttable=table;
end

elseif strcmp(rankreduction,'stereo'),
if Kest*D>1,
opttable=zeros(MM,Kest*D-1);
for c=1:MM,
opttable(c,:)=(table(c,1:D*Kest-1).^.5)/((1-table(c,D*Kest)).^.5);
end
else
opttable=table;
end

elseif strcmp(rankreduction,'svd'),
if MM>D*Kest,
opttable=classSVD(table);
else
opttable=kernelEVD(table);
end

end

SS=size(opttable);
MM=SS(1);
classlen=SS(2);

%**** Estimates L
Lpam=NaN;
Lward=NaN;
LEuclidean=NaN;
Lcentroid=NaN;
Lkmeans=NaN;
Lpam2=NaN;
Lward2=NaN;
LEuclidean2=NaN;
Lcentroid2=NaN;
Lkmeans2=NaN;

if strcmp(estimatesL,'ON') & MM<=1,
Lest=1;
Lpam=1;
Lward=1;
LEuclidean=1;
Lcentroid=1;
Lkmeans=1;
Lpam2=1;
Lward2=1;
LEuclidean2=1;
Lcentroid2=1;
Lkmeans2=1;
Lmeth='insufficientdata';
elseif strcmp(estimatesL,'ON') & sum(sum(var(opttable)<=.001))==classlen,
Lest=1;
Lpam=1;
Lward=1;
LEuclidean=1;
Lcentroid=1;
Lkmeans=1;
Lpam2=1;
Lward2=1;
LEuclidean2=1;
Lcentroid2=1;
Lkmeans2=1;
Lmeth='totalvar~0';
elseif strcmp(estimatesL,'ON') & MM>1,

MaxRangeOp=min(MaxRange,MM);

ttsil=zeros(1,MaxRangeOp);
wss=zeros(1,MaxRangeOp);

wss(1)=(MM-1)*sum(var(opttable));
for i=2:MaxRangeOp,
 % disp(['PAM ' num2str(i) ' ' num2str(MM)]);
try
[Medoids,clusters,DIST]=KMedoidshort(opttable,i,2,1);
for j=1:i,
    I=find(clusters==j);
    subtable=zeros(length(I),classlen);
    for h=1:length(I),
    	subtable(h,:)=opttable(I(h),:);
    end
    wss(i)=wss(i)+(length(I)-1)*sum(var(subtable));
end
ttsil(i)=sum(silhouette(opttable,clusters))/MM;
% ttsil(i)=sum(silhouetteCoeff(Medoids,DIST,clusters))/MM;
catch
end
% PAM=pam(opttable,i,4*ones(1,classlen),1,1,0); % last version
% PAM=pam(table,i,4); % previous version
% ttsil2(i)=PAM.ttsil;
end
if strcmp(silmode,'max'),
[silhou,candidate]=max(ttsil);
if silhou>=.5,
    Lpam2=candidate;
end
else
for i=1:MaxRangeOp,
if ttsil(i)>=maxSil,
    Lpam2=i;
    break;
end
end
end
wss=wss/wss(1);
for i=1:MaxRangeOp,
if wss(i)<=zeroSS,
    Lpam=i;
    break;
end
end
if strcmp(plotL,'ON'),
figure(figindex); figindex=figindex+1;
subplot(2,5,5);
plot(1:length(wss),wss,'-o',[1 length(wss)],[zeroSS zeroSS])
grid
title(['pam Elbow Lest=' num2str(Lpam)])
subplot(2,5,10);
plot(1:length(ttsil),ttsil,'-o',[1 length(ttsil)],[maxSil maxSil])
grid
title(['pam Sil MAT Lest=' num2str(Lpam2)])
end
%
wss=zeros(1,MaxRangeOp);
ttsil=zeros(1,MaxRangeOp);
dist=pdist(opttable,'euclidean');
link=linkage(dist,'ward');
for i=1:MaxRangeOp,
   % disp(['ward ' num2str(i) ' ' num2str(MM)]);
clusters=cluster(link,'maxclust',i);
for j=1:i,
    I=find(clusters==j);
    subtable=zeros(length(I),classlen);
    for h=1:length(I),
    	subtable(h,:)=opttable(I(h),:);
    end
    wss(i)=wss(i)+(length(I)-1)*sum(var(subtable));
end
ttsil(i)=sum(silhouette(opttable,clusters))/MM;
end
if strcmp(silmode,'max'),
[silhou,candidate]=max(ttsil);
if silhou>=.5,
    Lward2=candidate;
end
else
for i=1:MaxRangeOp,
if ttsil(i)>=maxSil,
    Lward2=i;
    break;
end
end
end
wss=wss/wss(1);
for i=1:MaxRangeOp,
if wss(i)<=zeroSS,
    Lward=i;
    break;
end
end
if strcmp(plotL,'ON'),
subplot(2,5,1)
plot(1:length(wss),wss,'-o',[1 length(wss)],[zeroSS zeroSS])
grid
title(['ward Elbow Lest=' num2str(Lward)])
subplot(2,5,6);
plot(1:length(ttsil),ttsil,'-o',[1 length(ttsil)],[maxSil maxSil])
grid
title(['ward Sil MAT Lest=' num2str(Lward2)])
end
%
wss=zeros(1,MaxRangeOp);
ttsil=zeros(1,MaxRangeOp);
dist=pdist(opttable,'euclidean');
link=linkage(dist,'centroid');
for i=1:MaxRangeOp,
  %  disp(['centroid ' num2str(i) ' ' num2str(MM)]);
clusters=cluster(link,'maxclust',i);
for j=1:i,
    I=find(clusters==j);
    subtable=zeros(length(I),classlen);
    for h=1:length(I),
    	subtable(h,:)=opttable(I(h),:);
    end
    wss(i)=wss(i)+(length(I)-1)*sum(var(subtable));
end
ttsil(i)=sum(silhouette(opttable,clusters))/MM;
end
if strcmp(silmode,'max'),
[silhou,candidate]=max(ttsil);
if silhou>=.5,
    Lcentroid2=candidate;
end
else
for i=1:MaxRangeOp,
if ttsil(i)>=maxSil,
    Lcentroid2=i;
    break;
end
end
end
wss=wss/wss(1);
for i=1:MaxRangeOp,
if wss(i)<=zeroSS,
    Lcentroid=i;
    break;
end
end
if strcmp(plotL,'ON'),
subplot(2,5,2);
plot(1:length(wss),wss,'-o',[1 length(wss)],[zeroSS zeroSS])
grid
title(['centroid Elbow Lest=' num2str(Lcentroid)])
subplot(2,5,7);
plot(1:length(ttsil),ttsil,'-o',[1 length(ttsil)],[maxSil maxSil])
grid
title(['centroid Sil MAT Lest=' num2str(Lcentroid2)])
end
%
wss=zeros(1,MaxRangeOp);
ttsil=zeros(1,MaxRangeOp);
wss(1)=(MM-1)*sum(var(opttable));
for i=2:MaxRangeOp,
try % disp(['kmeans Eucl ' num2str(i) ' ' num2str(MM)]);
[cidx, ctrs,sumD] = kmeans(opttable, i, 'dist','sqEuclidean', 'rep',5, 'disp','off');
wss(i)=sum(sumD);
ttsil(i)=sum(silhouette(opttable,cidx))/MM;
catch
% disp(['error at test i=' num2str(i)]);
end
end
if strcmp(silmode,'max'),
[silhou,candidate]=max(ttsil);
if silhou>=.5,
    LEuclidean2=candidate;
end
else
for i=1:MaxRangeOp,
if ttsil(i)>=maxSil,
    LEuclidean2=i;
    break;
end
end
end
wss=wss/wss(1);
for i=1:MaxRangeOp,
if wss(i)<=zeroSS,
    LEuclidean=i;
    break;
end
end
if strcmp(plotL,'ON'),
subplot(2,5,3);
plot(1:length(wss),wss,'-o',[1 length(wss)],[zeroSS zeroSS])
grid
title(['kmeans Eucl Elbow Lest=' num2str(LEuclidean)])
subplot(2,5,8);
plot(1:length(ttsil),ttsil,'-o',[1 length(ttsil)],[maxSil maxSil])
grid
title(['kmeans Eucl Sil MAT Lest=' num2str(LEuclidean2)])
end
%
wss=zeros(1,MaxRangeOp);
ttsil=zeros(1,MaxRangeOp);
wss(1)=(MM-1)*sum(var(opttable));
for i=2:MaxRangeOp,
ttsil(i)=-1;
try % disp(['kmeans corr ' num2str(i) ' ' num2str(MM)]);
[cidx, ctrs,sumD] = kmeans(opttable, i, 'dist','correlation', 'rep',5, 'disp','off');
wss(i)=sum(sumD);
ttsil(i)=sum(silhouette(opttable,cidx))/MM;
catch
% disp(['error at test i=' num2str(i)]);
end
end
if strcmp(silmode,'max'),
[silhou,candidate]=max(ttsil);
if silhou>=.5,
    Lkmeans2=candidate;
end
else
for i=1:MaxRangeOp,
if ttsil(i)>=maxSil,
    Lkmeans2=i;
    break;
end
end
end
wss=wss/wss(1);
for i=1:MaxRangeOp,
if wss(i)<=zeroSS,
    Lkmeans=i;
    break;
end
end
if strcmp(plotL,'ON'),
subplot(2,5,4);
plot(1:length(wss),wss,'-o',[1 length(wss)],[zeroSS zeroSS])
grid
title(['kmeans corr Elbow Lest=' num2str(Lkmeans)])
subplot(2,5,9);
plot(1:length(ttsil),ttsil,'-o',[1 length(ttsil)],[maxSil maxSil])
grid
title(['kmeans corr Sil MAT Lest=' num2str(Lkmeans2)])
end

Lvec=[Lpam Lpam2 LEuclidean LEuclidean2 Lkmeans Lkmeans2 Lward Lward2 Lcentroid Lcentroid2];
Lest=min(fastmode(Lvec));
% or
% if T<50,
% Lest=Lpam;
% else
% Lest=Lward2;
% end

I=find(Lvec==Lest);
if Lest>0,
if I(1)==1 | I(1)==2,
Lmeth='pam';
elseif I(1)==3 | I(1)==4,
Lmeth='Euclidean';
elseif I(1)==5 | I(1)==6,
Lmeth='kmeans';
elseif I(1)==7 | I(1)==8,
Lmeth='ward';
elseif I(1)==9 | I(1)==10,
Lmeth='centroid';
end
else
Lest=1;
Lmeth='notfound';
end

else
Lest=L;
Lmeth='pam';
end

%**** Plot
if strcmp(plotprocess,'ON'),
figure(figindex); figindex=figindex+1;

if strcmp(stdUnitFrechet,'yes'),
title('Unit-Frechet standardized data');
else
title('Original data');
end

hold on

if strcmp(graph,'mode1'),
for c=0:max(isExtreme),
for d=1:D,
    nbPoints=sum(isExtreme==c);
    xColor=zeros(1,nbPoints);
    inColor=zeros(1,nbPoints);
    j=1;
    for t=1:T,
        if isExtreme(t)==c,
            xColor(j)=t;
            inColor(j)=y(d,t);
            j=j+1;
        end
    end
    if c==0, col='b'; else col=color(mod(c,length(color))+1); end
    stem3(d*ones(1,nbPoints),xColor,inColor,col);
end
end
xlabel('d');
ylabel('time');
zlabel('Spot price');
view(45,30)
hold off

elseif strcmp(graph,'mode2'),
[XX,YY]=meshgrid(1:T,1:D);
plot3(XX,YY,y)

elseif strcmp(graph,'mode3'),
for t=1:T,
    if isExtreme(t)==0, col='b'; else col=color(mod(isExtreme(t),length(color))+1); end
    plot3(1:D,t*ones(1,D),y(:,t),col);
end
end

xlabel('d');
ylabel('time');
zlabel('Spot price');
view(45,30)
hold off

if strcmp(stdUnitFrechet,'yes'),
figure(figindex); figindex=figindex+1;
title('Original data');
hold on

if strcmp(graph,'mode1'),
for c=0:max(isExtreme),
for d=1:D,
    nbPoints=sum(isExtreme==c);
    xColor=zeros(1,nbPoints);
    inColor=zeros(1,nbPoints);
    j=1;
    for t=1:T,
        if isExtreme(t)==c,
            xColor(j)=t;
            inColor(j)=data(d,t);
            j=j+1;
        end
    end
    if c==0, col='b'; else col=color(mod(c,length(color))+1); end
    stem3(d*ones(1,nbPoints),xColor,inColor,col);
end
end
xlabel('d');
ylabel('time');
zlabel('Spot price');
view(45,30)
hold off

elseif strcmp(graph,'mode2'),
[XX,YY]=meshgrid(1:T,1:D);
plot3(XX,YY,data)

elseif strcmp(graph,'mode3'),
for t=1:T,
    if isExtreme(t)==0, col='b'; else col=color(mod(isExtreme(t),length(color))+1); end
    plot3(1:D,t*ones(1,D),data(:,t),col);
end
end

xlabel('d');
ylabel('time');
zlabel('Spot price');
view(45,30)
hold off
end

end

%**** Attempt to recover A

Ahat=zeros(Lest,Kest,D);
MM=max(max(isExtreme));
clusters=zeros(MM,1);

meth='noclust';

% method 'exact': mode of found profiles
if strcmp(clustering,'exact'),
meth='exact';

% creates a multivariate summary
Summary=zeros(MM,Kest,D);
Fingerprints=zeros(MM,1);
for c=1:MM,
t=1; while isExtreme(t)~=c, t=t+1; end
Summary(c,1:Kest,:)=y(:,t:t+Kest-1)';
for d=1:D,
    Summary(c,:,d)=Summary(c,:,d)/sum(Summary(c,:,d));
end
Fingerprints(c)=sum(sum((floor(10000*Summary(c,:,:))).^2));
end

if MM==1,

for l=1:Lest,
    Ahat(l,:,:)=Summary(1,:,:);
end

elseif MM<=Lest,

for l=1:Lest,
Ahat(l,:,:)=Summary(min(l,MM),:,:);
end
    
else

SummaryCopy=Summary;
FingerprintsCopy=Fingerprints;
FingerprintsUsed=zeros(Lest,1);
    
for l=1:Lest,

if isempty(FingerprintsCopy), break; end
len=length(FingerprintsCopy);

[FingerprintsUsed(l),B]=mode(FingerprintsCopy);

for c=1:len,
   if FingerprintsCopy(c) == FingerprintsUsed(l),
   Ahat(l,:,:)=SummaryCopy(c,:,:);
   break;
   end
end

% discard just used mode
for c=0:(len-1)
    if FingerprintsCopy(len-c) == FingerprintsUsed(l),
        SummaryCopy(len-c,:,:)=[];
        FingerprintsCopy(len-c)=[];
    end
end

end

% clusters
for l=1:Lest,
I=find(Fingerprints==FingerprintsUsed(l));
for i=1:length(I),
    clusters(I(i))=l;
end
end
  
end

% method 'approachedM': mean of found profiles
% method 'approachedU': mean of found profiles wrt d=1
elseif strcmp(clustering,'approachedM') || strcmp(clustering,'approachedU'),
    
% creates a multivariate summary
Summary=zeros(MM,Kest,D);
Fingerprints=zeros(MM,1);
for c=1:MM,
t=1; while isExtreme(t)~=c, t=t+1; end
Summary(c,1:Kest,:)=y(:,t:t+Kest-1)';
for d=1:D,
    Summary(c,:,d)=Summary(c,:,d)/sum(Summary(c,:,d));
end
if strcmp(clustering,'approachedM'),
	Fingerprints(c)=sum(sum((floor(10000*Summary(c,:,:))).^2));
else 	Fingerprints(c)=sum(sum((floor(10000*Summary(c,:,1))).^2));
end
end

   
if MM==1,

for l=1:Lest,
    Ahat(l,:,:)=Summary(1,:,:);
    clusters(l)=l;
end

elseif MM<=Lest,

for l=1:Lest,
    Ahat(l,:,:)=Summary(min(l,MM),:,:);
    clusters(l)=min(l,MM);
end

else

if strcmp(sortmode,'quadruple'),
% the quadruple sort (triple sort supposed to forget bad records)
meth='qsort';
ok=0;
errors=0;
SummaryCopy=Summary;
FingerprintsCopy=Fingerprints;
while ok==0 && errors <= 10 && length(FingerprintsCopy)>Lest;
[Y,I] = sort(FingerprintsCopy);
[Z,J] = sort(Y(2:length(FingerprintsCopy))-Y(1:length(FingerprintsCopy)-1));
clustersEnd=[0 sort(J(length(FingerprintsCopy)-Lest+1:length(FingerprintsCopy)-1)') length(FingerprintsCopy)];
[W,B] = sort(clustersEnd(2:length(clustersEnd))-clustersEnd(1:length(clustersEnd)-1));
if W(1)==1 && length(FingerprintsCopy)>=4,
    errors=errors+1;
    SummaryCopy(I(clustersEnd(B(1)+1)),:,:)=[];
    FingerprintsCopy(I(clustersEnd(B(1)+1)))=[];
else
    ok=1;
end
end
if errors>0 || length(FingerprintsCopy)>Lest, % do the triple sort
[Y,I] = sort(FingerprintsCopy);
[Z,J] = sort(Y(2:length(FingerprintsCopy))-Y(1:length(FingerprintsCopy)-1));
clustersEnd=[0 sort(J(length(FingerprintsCopy)-Lest+1:length(FingerprintsCopy)-1)') length(FingerprintsCopy)];
end

for l=1:Lest,
    num=zeros(D,Kest);
    for j=(clustersEnd(l)+1):clustersEnd(l+1),
        num=num+permute(SummaryCopy(I(j),:,:),[3 2 1]);
        clusters(I(j))=l;
    end
    Ahat(l,:,:)=permute(num/(clustersEnd(l+1)-clustersEnd(l)),[3 2 1]);
end

elseif strcmp(sortmode,'triple')
% the triple sort
meth='tsort';
[Y,I] = sort(Fingerprints);
[Z,J] = sort(Y(2:MM)-Y(1:MM-1));
clustersEnd=[0 sort(J(MM-Lest+1:MM-1)') MM];
for l=1:Lest,
    num=zeros(D,Kest);
    for j=(clustersEnd(l)+1):clustersEnd(l+1),
        num=num+permute(Summary(I(j),:,:),[3 2 1]);
        clusters(I(j))=l;
    end
    Ahat(l,:,:)=permute(num/(clustersEnd(l+1)-clustersEnd(l)),[3 2 1]);
end
end

end

elseif strcmp(clustering,'best') || strcmp(clustering,'ward') || strcmp(clustering,'pam'),

if strcmp(clustering,'best'),
meth=Lmeth;
else
meth=clustering;
end

if MM<=1,
clusters=1;
Lest=1;
Ahat(1,:,:)=permute(reshape(table(1,:),Kest,D)',[3 2 1]);

elseif Lest<=1,
Lest=1;
clusters=ones(MM,1);
Ahat(1,:,:)=permute(reshape(table(1,:),Kest,D)',[3 2 1]);

elseif strcmp(meth,'ward'),
dist=pdist(opttable,'euclidean');
link=linkage(dist,'ward');
clusters=cluster(link,'maxclust',Lest);
for l=1:Lest,
    num=zeros(D,Kest);
    I=find(clusters==l);
    for i=1:length(I),
    	num=num+reshape(table(I(i),:),Kest,D)';
    end
    Ahat(l,:,:)=permute(num/length(I),[3 2 1]);
end
elseif strcmp(meth,'centroid'),
dist=pdist(opttable,'euclidean');
link=linkage(dist,'centroid');
clusters=cluster(link,'maxclust',Lest);
for l=1:Lest,
    num=zeros(D,Kest);
    I=find(clusters==l);
    for i=1:length(I),
    	num=num+reshape(table(I(i),:),Kest,D)';
    end
    Ahat(l,:,:)=permute(num/length(I),[3 2 1]);
end
elseif strcmp(meth,'Euclidean'),
try
[clusters,ctrs]=kmeans(table, Lest, 'dist','sqEuclidean', 'rep',10, 'disp','off');
for l=1:Lest,
    Ahat(l,:,:)=permute(reshape(ctrs(l,:),Kest,D)',[3 2 1]);
end
catch
dist=pdist(opttable,'euclidean');
link=linkage(dist,'ward');
clusters=cluster(link,'maxclust',Lest);
for l=1:Lest,
    num=zeros(D,Kest);
    I=find(clusters==l);
    for i=1:length(I),
    	num=num+reshape(table(I(i),:),Kest,D)';
    end
    Ahat(l,:,:)=permute(num/length(I),[3 2 1]);
end
end
elseif strcmp(meth,'kmeans'),
try
[clusters,ctrs]=kmeans(table, Lest, 'dist','correlation', 'rep',10, 'disp','off');
for l=1:Lest,
    num=zeros(D,Kest);
    I=find(clusters==l);
    for i=1:length(I),
    	num=num+reshape(table(I(i),:),Kest,D)';
    end
    Ahat(l,:,:)=permute(num/length(I),[3 2 1]);
end
catch
dist=pdist(opttable,'euclidean');
link=linkage(dist,'ward');
clusters=cluster(link,'maxclust',Lest);
for l=1:Lest,
    num=zeros(D,Kest);
    I=find(clusters==l);
    for i=1:length(I),
    	num=num+reshape(table(I(i),:),Kest,D)';
    end
    Ahat(l,:,:)=permute(num/length(I),[3 2 1]);
end
end
elseif strcmp(meth,'pam'),
  %  disp(['PAM ' num2str(Lest) ' ' num2str(MM)]);
% PAM=pam(opttable,Lest,4*ones(1,classlen),1,1,0); % last version
% PAM=pam(opttable,Lest,4); % previous version
% clusters=PAM.ncluv';
try
[Medoids,clusters,DIST]=KMedoidshort(opttable,Lest,2,1);
for l=1:Lest,
    Ahat(l,:,:)=permute(reshape(table(Medoids(l),:),Kest,D)',[3 2 1]);
end
catch
dist=pdist(opttable,'euclidean');
link=linkage(dist,'ward');
clusters=cluster(link,'maxclust',Lest);
for l=1:Lest,
    num=zeros(D,Kest);
    I=find(clusters==l);
    for i=1:length(I),
    	num=num+reshape(table(I(i),:),Kest,D)';
    end
    Ahat(l,:,:)=permute(num/length(I),[3 2 1]);
end
end

end

end

%**** Adjusts Ahat
if strcmp(recoversprofiles,'equiprobable'),
Ahat=setfreq(Ahat,T);
else
frequencies = zeros(1,Lest);
for l=1:Lest,
    I=find(clusters==l);
    frequencies(l)=length(I)/(MM-sum(clusters==0));
end
Ahat=setfreq(Ahat,T,frequencies);
end

%**** Plots Ahat
if strcmp(viewwindow,'ON'),
figure(figindex); figindex=figindex+1;
i=1;
for l=1:Lest,
    for k=1:Kest;
        subplot(Kest*Lest,1,i);
        plot(squeeze(Ahat(l,k,:)));
        title(['Estimation (l=' num2str(l) ', k=' num2str(k) ')']);
        i=i+1;
    end
end
end

%**** Results
Kvec=[K1 K2 K3 K4 K5 K6 K7 K8 K9 K10 K11 K12 K13];
Lvec=[Lpam Lpam2 LEuclidean LEuclidean2 Lkmeans Lkmeans2 Lward Lward2 Lcentroid Lcentroid2];

%**** Output
if strcmp(estimatesK,'ON'),
    disp(['Estimators of K: ', num2str(Kvec)]);
    disp(['Estimation of K: ', num2str(Kest)]);
else
    disp(['Value of K: ', num2str(K)]);
end
if strcmp(estimatesL,'ON'),
    disp(['Estimators of L: ', num2str(Lvec)]);
    disp(['Estimation of L: ', num2str(Lest)]);
else
    disp(['Value of L: ', num2str(L)]);
end
if strcmp(stdUnitFrechet,'yes'),
    disp('Model for unit-Fr�chet standardized data: stored in Ahat (type Ahat)');
else
    disp('Model for original data: stored in Ahat (type Ahat)');
end
disp(['Number of blocks of extremes gathered: ',num2str(Q)]);
disp('Found frequencies for (Profile 1, ..., Profile L): ');
if ~strcmp(recoversprofiles,'equiprobable')
disp(num2str(frequencies));
end
disp(['Extremal clustering: ',meth]); 
disp('')

%**** Simulation if requested
if simlength>0,

sim=zeros(D,simlength);
Z=(-1./log(rand(Lest,simlength+Kest-1))).^(1/alpha); % Z=iidFrechetArray(Lest,simlength+Kest-1,alpha);
for d=1:D,
    for t=1:simlength, sim(d,t)=max(max((fliplr(Ahat(:,:,d)).*Z(:,t:Kest+t-1))')); end 
end

figure(figindex); figindex=figindex+1;
title('Simulation of the model with unit-Frechet innovations');
hold on
[XX,YY]=meshgrid(1:simlength,1:D);
stem3(YY,XX,sim)
xlabel('d'); ylabel('time'); zlabel('Spot price'); view(45,30)
grid
hold off

end

warning on all
