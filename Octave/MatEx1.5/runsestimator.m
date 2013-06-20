function len=runsestimator(Y,ratio,runs,method)
% RUNSESTIMATOR   Generalized runs estimator for the length of tail
% dependence of a positive univariate or multivariate time series.
%
% RUNSESTIMATOR(Y, RATIO, RUNS, METHOD) estimates the length of tail
% dependence of a positive multivariate time series Y, each row being
% a vector of observations. RATIO is a scalar or a column vector
% indicating the coefficient(s) to apply to the maximum of each variable
% to determine the threshold above which the values are considered as
% extremes (by default 0.20). RUNS is the number of consecutive values
% allowed below the threshold after an extreme value so that new extremes
% belong to the same cluster (by default 0). METHOD, either 'median',
% 'mode' or 'mean', is the method to compute the average cluster size of
% extremes (by default 'median').
%
% Y is scanned componentwise. The returned value is
% 1/(average length of tail dependence).
%
% Examples:
% 1/runsestimator([1 101 99 2 102], 0.50, 0, 'median') is 1.5 whereas
% 1/runsestimator([1 101 99 2 102], 0.50, 1, 'median') is 4
%
% Y = [1 10 11 12 1 10 1 ; 1 10 11 12 1 10 11];
% 1/runsestimator(Y, 0.50, 0, 'median') is median([3 1 3 2]) = 2.5
% 1/runsestimator(Y, 0.50, 0, 'mode') is mode([3 1 3 2]) = 3
% 1/runsestimator(Y, 0.50, 0, 'mean') is mean([3 1 3 2]) = 2.25
%
% Classical runs estimator of the extremal index:
% 1/runsestimator(max(Y), 0.50, 0, 'mean') = 2.5
%
% Written by Thomas Meinguet on March 22, 2010.
% MatEx version 1.2

if nargin < 4, method='median'; end
if nargin < 3, runs=0; end
if nargin < 2, ratio = 0.2; end

if ratio<=0 || ratio >1, 
    warning(['Invalid ratio ' num2str(ratio)]);
end

Size=size(Y);
Max=max(Y');
threshold=Max'.*ratio;

extreme=0;
curlength=0;
r=0;
lengths=[];
i=0;

for d=1:Size(1),
   for t=1:Size(2),
       if Y(d,t) >= threshold(d),
           curlength=curlength+1+r;
           extreme=1;
           r=0;
           if t==Size(2),
               i=i+1;
               lengths(i)=curlength;
           end
       else
           if extreme==1 && r <runs,
                if t==Size(2),
                    i=i+1;
                    lengths(i)=curlength;
                else
                    r=r+1;
                end
           elseif extreme==1,
               i=i+1;
               lengths(i)=curlength;
               extreme=0;
               curlength=0;
               r=0;
           end
       end
   end
   extreme=0;
   curlength=0;
   r=0;
end

if strcmp(method,'median'),
    len=1/median(lengths);
elseif strcmp(method,'mode'),
    len=1/max(fastmode(lengths));
elseif strcmp(method,'mean'),
    len=length(lengths)/sum(lengths);
else
    warning(['Invalid method ' method ', median used instead']);
    len=1/median(lengths);
end
