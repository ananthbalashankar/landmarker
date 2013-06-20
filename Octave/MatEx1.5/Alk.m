function y=Alk(l,k,x)
% Alk   Parameter functions for a CM3
%
% Put here the parameter functions defind on [0,1] for a CM3 that you
% want to generate by
%
% A = zeros(L,K,D);
% for l=1:L,
% for k=1:K,
%     for d=1:D,
%         A(l,k,d)=Alk(l,k,d/D);
%     end
% end
% end
% for d=1:D, A(:,:,d)=A(:,:,d)/sum(sum(A(:,:,d))); end
%
% k is the index for the temporal dependence and l is the index for
% the number of patterns.
%
% A will be a LxKxD-array with the process parameters where L is the
% number of profiles, K the length of the temporal dependence and D the
% dimension of the space (number of measurement points).
%
% Written by Thomas Meinguet on January 30, 2010.
% MatEx version 1.0


if k==1 & l==1,
    
y=2+sin(2*pi*x);

elseif k==2 & l==1,
    
y=2;
    
elseif k==3 & l==1,
    
y=1+x;

elseif k==1 & l==2,
    
y=2+x*x*x;

elseif k==2 & l==2,
    
y=2-x;
    
elseif k==3 & l==2,
    
y=.5+cos(x);

elseif k==1 & l==3,
    
y=2-sqrt(x);

elseif k==2 & l==3,
    
y=1.5+cos(2*pi*x);    

elseif k==3 & l==3,
    
y=.1+x;

end
