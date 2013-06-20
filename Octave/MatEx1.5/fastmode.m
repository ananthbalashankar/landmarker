function [y, n]=fastmode(x)
% FASTMODE  Returns the most frequently occuring element
% 
%   y = fastmode(x) returns the element in the vector 'x' that occurs the
%   most number of times. If more than one element occurs at equal
%   frequency, all elements with equal frequency are returned.
% 
%   [y, n] = fastmode(x) does the same as above but also returns the
%   frequency of the element(s) in 'n'.
% 
%   Note that due to speed considerations, no error checking is performed
%   on the input data. Matrices will be reduced to vectors via the colon
%   (:) operator, NaN's are ignored.
% 
%   Example
%   % Generate a data set of values between 0 and 9
%   >> data=fix(rand(1000,1).*9);
%   % Get the most common value and its frequency
%   >> [mode, n]=fastmode(data);
%   % To confirm, run this simple script
%   >> for i=1:9 disp(sprintf('Element %d: Frequency %d', i,
%   length(data(data==i)))); end;
% 
%   % Note if you give it only unique values, all values will be
%   % returned with a frequency count of 1, i.e.
%   >> [y, n]=fastmode([1:9]);
%   % will result in y=[1:9] and n=1
% 
%   See also MEAN, MEDIAN, STD.

%   Copyright 2006 Harold Bien
%   $Revision: 1.0 $    $Date: 2006/04/13 $

% This code was evolved from mode.m by Michael Robbins and critical input
% by others in MathWorks FileExchange

% The data must be sorted in order for this algorithm to work
sorted=sort(x(:));
% Compute element-by-element difference. This will return 0 for
% identical valued elements (since it is sorted) and non-zero for 
% different elements. We add a dummy element at the end in order to
% pick up repeated elements at the end (make sure last element is not
% equal to the next-to-last element). This value will never be used for
% mode computations, so it's safe to add in.
dist=diff([sorted; sorted(end)-1]);
% This gives us unique values (presumably faster than unique())
% [Profiler indicates a lot of time spent here, so we avoid it]
%unique_vals=sorted(dist~=0);
% Find locations of all non-zero elements and take the difference
% which counts how many of each element is there. The first repeated
% elements are dropped in the dist, so we add it back in as the first
% non-zero index, i.e. the first non-zero index indicates that many
% repeated first entries
% Get non-zero entries
idx=find(dist);
num=[idx(1); diff(idx)];
% Get the mode, including possible duplicates
n=max(num);
% Pull the values from the original sorted vector
y=sorted(idx(num==n));