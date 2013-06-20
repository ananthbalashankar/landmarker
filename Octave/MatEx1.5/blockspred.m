function blockspredicted=blockspred(A)
% BLOCKSPRED   Expected proportion of the extremal patterns in CM3 / M4
%
% A is LxKxD-array with the process parameters where L is the number of
% profiles, K the length of the temporal dependence and D the dimension
% of the space (number of measurement points).
%
% BLOCKSPRED(A) is a 1xL-vector giving the probabilites of occurrence of
% every extremal pattern
%
% Example:
% blockspred([.20 .35 .5 ; .10 .20 .10])
% ans =
%    0.1108    0.0385
%
% Written by Thomas Meinguet on January 30, 2010.
% MatEx version 1.0
%
%
%   See also SETFREQ.

Size=size(A);

L=Size(1);
K=Size(2);

blockspredicted=zeros(1,L);
m=zeros(L,2*K-1);

for lstar=1:L,

for l=1:L,
for k=1:K,
m(l,k)=min(min(A(lstar,1:k,:)./A(l,K-k+1:K,:)));
m(l,2*K-k)=min(min(A(lstar,K-k+1:K,:)./A(l,1:k,:)));
end
end

h = hm(m);
blockspredicted(lstar)=h/((2*K-1)*L);
end

