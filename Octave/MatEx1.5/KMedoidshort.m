function [Medoids,clusvector,DIST]=KMedoidshort(M,N,dist,T)
% KMedoidshort   Partitioning Around Medoids algorithm
%
% INPUT
% Clustering of the rowvectors of the Matrix M
% N: nr of clusters to be found
% dist: mode of function Distance
% T=Timevector when using slope distance, Weight vector when using
% Minkowski Distance

% OUTPUT
% Medoids: rowvector of the rownumber of the Medoid/cluster
% clusvector: nr of cluster for each object
% DIST: Distances matrix 
%
% Recieved from the Section of Statistics, Department of Mathematics at the
% Katholieke Universiteit Leuven, Belgium.
% Adapted by Thomas Meinguet on January 30, 2010.
%
% MatEx version 1.0

nrfeatures = 2;
[nrobjects]=size(M{1},2);

if ~isempty(dist)
    if dist>0
       %  disp('calculating distances');
        DIST=zeros(nrobjects, nrobjects);
    else 
        switch dist
        case -2
       %     disp('calculating distances (MAHALONOBIS)');
            DIST=zeros(nrobjects, nrobjects);
        case -3
       %     disp('calculating similarities (PEARSON CORR)');
            DIST=ones(nrobjects, nrobjects);
        case -4
       %     disp('calculating similarities (COSINE)');
            DIST=ones(nrobjects, nrobjects);
        otherwise error('Check this option in the code or choose other distance')
        end
    end  
    for i=1:nrobjects-1
        for j=i+1:nrobjects
         DIST(i,j)=wifiSimilarity(M,i,j);
         DIST(j,i)=DIST(i,j);
     	end
    end

else 
    disp('input treated as a DIS-SIMILARITY matrix ');
    DIST=M;

end
 
%BUILD
Medoids=[];

sumdist=sum(DIST);
[Min Medoids(1)]=min(sumdist);

for k=2:N
   notselected=setdiff([1:nrobjects],Medoids);
   Cj=zeros(nrobjects,1);
   for i=notselected             
      for j=notselected(find(notselected~=i))
     % for j=notselected
         Dj=min( DIST(j,Medoids) );
         dij=DIST(j,i);
         Cj(i)=Cj(i)+max([Dj-dij 0]);
      end
   end
   [Max Medoids(k)]=max(Cj); %selected ones have score zero 
end                          %(no problem: not selected ones have always positive score (i==j))

%SWAP
notselected=setdiff([1:nrobjects],Medoids);
ns=nrobjects-N;  %=length(notselected);

minT=-1;
T=zeros(N,ns);
iter=0;
% sumD=[];
while (minT<0 && iter<=20)
   
for i=Medoids 
   for h=notselected
      Cjih=0;
      for j=union(notselected,i)    %All the notselected objects IF the swap is carried out+the gain that the newly selected object has
         Dj=min( DIST(j,Medoids) );
         dij=DIST(j,i);
         dhj=DIST(j,h);
         if Dj==dij
            Ej=min( DIST(j,Medoids(find(Medoids~=i)) ));
            if dhj<Ej
               Cjih=Cjih + dhj-dij;
            else 
               Cjih=Cjih + Ej-Dj;
            end
         elseif Dj>dhj
            Cjih=Cjih + dhj-Dj;
         end
      end
      T(find(Medoids==i),find(notselected==h))=Cjih;
   end
end
[minT,Ind]=min(T(:));
if minT<0
   colh=ceil(Ind/N);
   rowi=Ind-(colh-1)*N;
   i=Medoids(rowi);
   Medoids(rowi)=notselected(colh);
   notselected(colh)=i;
end
iter=iter+1;
% sumiter=0;
% 
% for j=notselected
%    sumiter =sumiter+min( DIST(j,Medoids) );
% end

% sumD=[sumD sumiter];
end

%figure(1);
%plot(sumD);


%Information about the clustering
%we have DIST, Medoids

%clusvector 
clusvector=zeros(nrobjects,1);

for i=Medoids
   clusvector(i,1)=find(Medoids==i,1,'first');
end
for j=notselected
   [Dj Ind]=min( DIST(j,Medoids) );
   clusvector(j,1)=Ind;
end

