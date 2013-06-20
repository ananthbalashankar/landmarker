function [k] = optKinKmeans( x,max_cluster,startCtrs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

 if(size(x,1)==0)
     k=0;
     return;
 end
 

[row,dim]=size(x);

%calculation of alpha

for(i=2:max_cluster)
    if(i == 2)
        alphas=[1-(3/(4*dim))];
    else
        alphas=[alphas , alphas(1,i-2) + ((1-alphas(1,i-2))/6)];
    end
end

clear idx

% try
 %for mc=1:max_cluster
%[idx,startCtrs] = kmeans(x,mc);
%mc;
 %end
 %catch me1
%max_cluster=mc-1;
 %end
 
 %s=warning('error','stats:kmeans:FailedToConverge');
%x
%startCtrs
try
	if( size(x,2) == size(startCtrs,2) )
		[idx,ctrs,sumd]=kmeans(x,min(size(x,1),1),'start',startCtrs(1,:),'MaxIter', 3000);
	else
		[idx,ctrs,sumd]=kmeans(x,min(size(x,1),1),'MaxIter', 3000);
	end
catch ex
    size(x)
    size(startCtrs)
    k=0;
    return;
end

%[idx,ctrs,sumd]=kmeans(x,1,'start','cluster');
Sk = [sum(sumd)];
Fk = [1];

errI = [];
for i=2:max_cluster
%     try
%          i;
            if(i<=size(startCtrs,1))
                [idx,ctrs,sumd] = kmeansMod(x,i,startCtrs(randperm(size(startCtrs,1),i),:));
            else
                break;
            end
%          while true
%              try
%                 [idx,ctrs,sumd]=kmeans(x,i,'start',startCtrs(randsample(length(startCtrs),i),:),'MaxIter',2000);
%              catch err
%                  disp(strcat('error at  ',num2str(i)));
%                  errI = [errI,i];
%                  continue; 
%              end
%              break
%          end
        %[idx,ctrs,sumd]=kmeans(x,i,'start','cluster');
        Sk = [Sk,sum(sumd)];

        if(Sk(1,i) == 0)
            Fk=[Fk,1];
        else
            Fk=[Fk,Sk(1,i)/(alphas(1,i-1)*Sk(1,i-1))];
        end
%     catch err
%         disp(strcat('error at  ',num2str(i)));
%         errI = [errI,i];
%         break;
%     end
end
%warning(s);
minVal = min(Fk);

col= length(Fk);
k=1;
for(i=1:col)
    if(Fk(i) == minVal && isempty(find(errI==i)))
        k=i;
        break;
    end
end
%startCtrs(1,:);

end

