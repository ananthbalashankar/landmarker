function isExtreme=extremeblocks(Y,K,nbmax,method)
% EXTREMEBLOCKS   Find blocks of extremes in a univariate or a multivariate
% positive time series.
%
% ISEXTREME = EXTREMEBLOCKS(Y,K,NBMAX,METHOD) finds the blocks of extremes
% of a multivariate time series Y, each row being a vector of observations.
% K is the temporal length of the blocks to find. NBMAX is the maximal
% number of blocks to extract. METHOD, either 'cross-section' or 'profile',
% is the way to obtain the blocks (by default 'cross-section'). If METHOD
% is 'cross-section' the blocks are chosen to maximize within the number of
% large values in all variables . In case of ex aequo, it selects the
% block that maximizes the sum of the max-norms. If METHOD is 'profile'
% the algorithm localizes the most frequent patterns among the blocks of
% length K assuming they are blocks of extremes (for exact M4 only).
%
% The output ISEXTREME is vector of the same length as Y containing zeros
% everywhere but tagging the location of the blocks found this way:
% 'cross-section': 1 is the largest one, 2 the second largest etc.
% 'profile': 1 is an instance of the most frequent pattern, 2 an instance
% of the second most frequent pattern etc.
%
% Example:
% extremeblocks([1 10 10 1 50 50 1], 2, 2,'cross-section')
% ans =
%      0     2     2     0     1     1     0
%
% Written by Thomas Meinguet on January 30, 2010.
% MatEx version 1.0

if nargin < 4, method='cross-section'; end

if ~strcmp(method,'cross-section') && ~strcmp(method,'profile'),
    method='cross-section';
    warning(['Invalid method ' method ', ''cross-section'' used instead']);
end

Size=size(Y);
isExtreme=zeros(1,Size(2));

if strcmp(method,'cross-section'),

yCopy = Y;

MovingSum=zeros(1,Size(2));
MaxMovingSum=K;
found=0;
errorStatut=0;
errorMax=floor(Size(2)/K);
c=1;
while c<=nbmax;

[ySorted,I]=sort(yCopy');
ySorted=ySorted';
I=I';

tempExtreme=zeros(Size(1),Size(2));
for d=1:Size(1),
    for t=Size(2)+1-K:Size(2),
        tempExtreme(d,I(d,t))=1;
    end
end

if Size(1)>1, likelihood=sum(tempExtreme);
else    likelihood=tempExtreme;
end

for t=K:Size(2),
    MovingSum(t)=sum(likelihood(t-K+1:t));  
end

ma=max(MovingSum);
I=find(MovingSum==ma);
lengthI=length(I);
if lengthI==1,
    
MaxMovingSum=I(1);

else

start=1;
len=lengthI+1;
tmplen=1;
for i=2:lengthI,
if i<lengthI,
    if I(i-1)+1==I(i),
    tmplen=tmplen+1;
    else
        if tmplen<len,
            len=tmplen;
            start=i-len;
        end
        tmplen=1;
    end
else
    if I(i-1)+1==I(i),
    tmplen=tmplen+1;
    else
        tmplen=1;
    end
    if tmplen<len,
    len=tmplen;
    start=i-len+1;
    end
end

end
if len==1,
MaxMovingSum=I(start);
else
totalsum=zeros(1,len);
for i=0:len-1,
    totalsum(i+1)=sum(max(Y(:,I(start+i)-K+1:I(start+i))));
end
ma=max(totalsum);
J=find(totalsum==ma);
MaxMovingSum=I(start+J(1)-1);
end

end

if sum(isExtreme(MaxMovingSum-K+1:MaxMovingSum)==0)==K,
    isExtreme(MaxMovingSum-K+1:MaxMovingSum)=c;
    yCopy(:,MaxMovingSum-K+1:MaxMovingSum)=0;
else
    yCopy(:,MaxMovingSum-K+1:MaxMovingSum)=0;
    if errorStatut==errorMax, break; end
    c=c-1;
    errorStatut=errorStatut+1;
end
c=c+1;
end

elseif strcmp(method,'profile'),

profile = zeros(Size(1),K);
score = ones(2,Size(2)+1-K);

for t=K:Size(2),    
    profile = Y(:,t-K+1:t);
    for d=1:Size(1), profile(d,:)=profile(d,:)/sum(profile(d,:)); end
    score(1,t-K+1)=sum(sum(  floor( profile.*reshape(ceil(max([Size(1)*Size(2) 1/(max(max(Y))-min(min(Y)))]))*(1:Size(1)*K).^2,Size(1),K) )  ));
    if t>K, score(2,t-K+1)=sum(score(1,t-K+1)==score(1,1:t-K+1)); end
end

c=1;
I=1;

for l=1:nbmax,
[curMax,I] = max(score(2,:));
if curMax==1,
    if l==1, isExtreme(1:K)=1; end
    break;
end
curSco = score(1,I);
for t=1:Size(2)+1-K,
    if score(1,t)==curSco,
        score(2,t)=-l; 
    end
end
if sum(isExtreme(I:I+K-1)>0)>0,
    c=c-1;
    continue;
end
isExtreme(I:I+K-1)=c;
c=c+1;
end

end
