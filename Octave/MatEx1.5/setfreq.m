function B=setfreq(A,T,FREQ,ERRORMAX,ITERMAX)
% SETFREQ   Modify the probability of occurrence of the extremal patterns
% in CM3 / M4
%
% B=SETFREQ(A,T,FREQ,ERRORMAX,ITERMAX) is a LxKxD-array with the same
% multivariate patterns as in A but weigthed with the new frequencies.
% A is LxKxD-array with the process parameters where L is the number of
% profiles, K the length of the temporal dependence and D the dimension
% of the space (number of measurement points). T is the length of chain
% on which the output will be used, to compute the maximal error only
% (by default T=1 meaning it does not take that into account).
% FREQ is a 1xL-vector containg the new frequencies (by defaut the same).
% ERRORMAX is the maximal error allowed for a chain of length 1 (by
% defaut ERRORMAX=0.001). ITERMAX is the maximal number of iteration if
% ERRORMAX is not achieved (by defaut ITERMAX=100).
%
% Example:
% A=[.20 .35 .5 ; .10 .20 .10];
% blockspred(A)
% ans =
%     0.1108    0.0385
% B=setfreq(A)
% ans =
%     0.0924    0.1616    0.2309
%     0.1288    0.2575    0.1288
% blockspred(B)
% ans =
%     0.0725    0.0724
%
% Written by Thomas Meinguet on January 30, 2010.
% MatEx version 1.0
%
%
%   See also BLOCKSPRED.

Size=size(A);

% Size(1) = number of profiles
% Size(2) = length of the temporal dependence
% Size(3) = dimension of the space

if nargin < 5, ITERMAX=100; end
if nargin < 4, ERRORMAX=0.001; end
if nargin < 3, FREQ=ones(1,Size(1))/Size(1); end
if nargin < 2, T=1; end

B=A;
L=Size(1);

if L>1 && length(FREQ)==L,

ERRORMAX=ERRORMAX/T;
for i=1:ITERMAX,
bp=blockspred(B);
if max(abs((bp/sum(bp)-FREQ))) < ERRORMAX, break; end
for l=1:L, 
B(l,:,:)=B(l,:,:)*FREQ(l)/(bp(l));
end
end

end

% Standardization
if numel(Size)<=2,
B(:,:)=B(:,:)/sum(sum(B(:,:)));
else
for d=1:Size(3), B(:,:,d)=B(:,:,d)/sum(sum(B(:,:,d))); end
end
