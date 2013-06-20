function [ ids, ctrx, sumd ] = kmeansMod( data, max_clstrs, ctrs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    try
        [ ids, ctrx, sumd ] = kmeans( data, min(size(data,1),max_clstrs), 'start', ctrs, 'MaxIter', 2000);
    catch 
        [ ids, ctrx, sumd ] = kmeans( data, min(size(data,1),max_clstrs), 'emptyaction','singleton','MaxIter', 2000);
        [ ids, ctrx, sumd] = kmeansMod( data, min(size(data,1),max_clstrs), ctrx); 
    end
    
end

