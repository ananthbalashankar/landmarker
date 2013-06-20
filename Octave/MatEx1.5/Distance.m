function d = Distance(A,B,mode,varargin)
% Distance
%
% This function calculates the distance between the rowvectors of a matrix
% A(m,n) and a rowvector B(1,n),
% allowing NaN's.
% mode=1: Manhattan distance
% mode=2: Euclidian distance
% mode=i (i a natural number): Minkowski distance in general
% mode=inf: infinite norm
% mode=-1: Timevectors (slopes) distance. Varargin{1} contains the
%          Timevector
% mode=-2: Mahalanobis distance. Now, B is a matrix B(k,n), where k>d+1 and
%          the estimate of the covariance matrix is only
%          good when k>d(d-1)/2. Not yet implemented for missing values
%          Or varargin{1} contains the covariance matrix and B is the mean
%          (rowvector). (with missing values)
%          
% mode=-3: 1 - Pearson correlation
% mode>0 or mode=-3: weighted distances are possible (weight vector in
%                    varargin)
% d(m,1) contains the m distances
%
% Recieved from the Section of Statistics, Department of Mathematics at the
% Katholieke Universiteit Leuven, Belgium.
% Adapted by Thomas Meinguet on January 30, 2010.
%
% MatEx version 1.0


[rA,cA]=size(A);
[rB,cB]=size(B);


if (cA~=cB) error('The matrices must have the same columnsize');end



if mode>0 %General Minkowski distances
      
   if (rB~=1) error('The second matrix must be a rowvector');end
   Dif=abs(A-ones(rA,1)*B);
   L1=sum(finite(Dif),2);
   Dif(find(~finite(Dif)))=0;
   if  nargin>3
      % a Weight Vector is given
      W=varargin{1};
      if ~finite(mode)
         d=max(Dif.*(ones(rA,1)*W),[],2);
      else
         d=( sum( (Dif.^mode).*(ones(rA,1)*W) ,2) * cA./L1 ).^(1/mode);
      end
   else
      if ~finite(mode)
         d=max(Dif,[],2);
      else
         d=(sum((Dif.^mode),2)*cA./L1).^(1/mode);
      end
   end
   for i=1:rA 
      if(L1(i)==0) 
         disp(['The vector in row ',num2str(i),' of the first matrix and the rowvector dont have features in common']); 
         d(find(L1==0))=NaN;  
      end 
   end
   
else %Specialized 'distance' measures (SIMILARITY) 
   switch mode
       
   case -1,  
       %Timevectors
      for i=1:rA
         d(i)=slopes(varargin{1},A(i,:),B);
      end
      d=d(:);
      
   case -2,
       %Maholonobis
         if ~isempty(varargin)
         C=varargin{1};
         for i=1:rA
            X=(A(i,:)-B);
            L1=sum(finite(X));
            if(L1==0) 
               error('Vector',num2str(i),' of the first matrix and the rowvector dont have features in common'); 
            end
         X(find(~finite(X)))=0;
         d(i)=(X*C^(-1)*X')*rA/L1;
         end
         d=d(:);
      elseif sum(sum((~finite([A;B])),1),2)>0
         error('Mahalanobis with missing values not yet implemented');
      else
         d=mahal(A,B);
      end
      
   case -3
       %Pearson correlation
       if nargin>3
         W=varargin{1};
         d= 1-correlation(A,B,1,W);
      else
         d= 1-correlation(A,B,1);
      end    
      
      
      
  case -4
      %Cosine
      for i=1:rA
          d(i)=0;
          for j=1:cA
            d(i)=d(i)+A(i,j)*B(1,j);
          end
          d(i)=d(i) / (norm(A(i,:))*norm(B));
      end
 otherwise,
	error('No appropriate distance found');
 end
     
end

