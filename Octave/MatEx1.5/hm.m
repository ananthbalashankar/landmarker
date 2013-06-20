function HM=hm(A),
% HM   Harmonic mean
%
% HM(A) is the harmonic mean of all the real numbers in the matrix A 
%
% Example:
% hm([1 2 ; 3 4])
% ans =
%     1.9200
%
% Written by Thomas Meinguet on January 30, 2010.
% MatEx version 1.0

Size=size(A);
n=Size(1)*Size(2);
HM=n/sum(1./reshape(A,1,n));
