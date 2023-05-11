function width = widthHalfHeightGauss(sigma)

% function widthHalfHeightGauss(sigma)
%
%   example call: widthHalfHeightGauss(1)
%  
% width at half height of a gaussian from the standard deviation
%
% sigma:
%%%%%%%%
% width 

width = 2.*sqrt(2.*log(2)).*sigma;