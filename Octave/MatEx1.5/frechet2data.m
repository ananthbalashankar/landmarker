function dt=frechet2data(data,y)
% FRECHET2DATA   Non parametric recovery from unit-Fréchet margins.
%
% DATA = FRECHET2DATA(DATA0,Y) destandardizes the multivariate time series
% Y, each row being a vector of observations, so that the resulting
% dataset has the same margins as DATA0.
%
% Example:
% DATA0=[3 7 5 ; 1 2 3];
% FRE=data2frechet(DATA0)
% FRE =
%     0.5581    5.4848    1.4427
%     0.5581    1.4427    5.4848
% frechet2data(DATA0,FRE)
%     3     7     5
%     1     2     3
%
% Written by Thomas Meinguet on June 9, 2010.
% MatEx version 1.4
%
%
%   See also DATA2FRECHET.

Size=size(data);
D0=Size(1);
n0=Size(2);
Size=size(y);
D=Size(1);
n=Size(2);

if D0 ~= D,
error('Dimensions of DATA and Y must agree.');
end

U=zeros(D,n0);

U=exp(-1./y)+.5/n;

dt=zeros(D,n);
[X,I]=sort(data');
[q,I]=sort(U');

for d=1:D,
i=1;
for j=1:n0,
while i<=n && q(i,d)<=j/n0,
    dt(d,I(i,d))=X(j,d);
    i=i+1;
end
end
end
