function [edg,ctr]=histCircEdges(Xminmax,numBins)

% function [edg,ctr]=histCircEdges(Xminmax,numBins)
%
%   example call: [edg ctr]=histCircEdges([0 180],2^4)
%
% create bin edg designed for histogramming a circular variable
% 
%   i)   the first bin is centered at Xminmax(1)
%   ii)  the first and last bins are half the size of the other bins
%   iii) the first and last bins will have their inputs combined
% 
% Xminmax: min and max value of variable    [ 1 x 2 ]
% numBins: number of bin centers
% %%%%%%%%%%%%%%%%
% edg:   bin edg    [ 1 x numBins+2 ]
% ctr:   bin centers  [ 1 x numBins   ]
%
% see histcounts.m

if length(unique(numBins)) == 1, numBins = numBins(1); end

A = linspace(Xminmax(1),Xminmax(2),numBins+1); 
B = diff(A)./2+A(1:end-1);  

% EDGES
edg = [Xminmax(1) B Xminmax(2)];
% CENTERS 
ctr = A(1:end-1);