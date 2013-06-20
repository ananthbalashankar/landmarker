function UF=data2frechet(data)
% DATA2FRECHET   Non parametric standardization into unit-Fréchet margins.
%
% FRE = DATA2FRECHET(DATA) standardizes the multivariate time series Y,
% each row being a vector of observations, so that the resulting dataset
% has unit-Fréchet margins.
%
% This standardization uses the empirical cumulative distribution function.
%
% Example:
% data2frechet([3 7 5 ; 1 2 3])
% ans =
%   0.5581    5.4848    1.4427
%   0.5581    1.4427    5.4848
%
% Written by Thomas Meinguet on June 9, 2010.
% MatEx version 1.4
%
%
%   See also FRECHET2DATA.

Size=size(data);

D=Size(1);
n0=Size(2);
UF=zeros(D,n0);

[X,I]=sort(data');

for d=1:D,
for i=1:n0,
UF(d,I(i,d))=-1/log((i-.5)/n0);
end
end

