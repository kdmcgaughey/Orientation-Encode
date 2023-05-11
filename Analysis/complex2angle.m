function [aRad, mag] = complex2angle(c,nPeriod)

% function [aRad mag] = complex2angle(c,nPeriod)
% 
%   example call: complex2angle(1/sqrt(2)+1i/sqrt(2))
%
% convert angle in degrees to complex number
%
% c:        complex number of arbitrary magnitude
% nPeriod:  period of angles (i.e. [0 180) has nPeriod = 2)
% %%%%%%%%%%%%%%
% aRad:     angle in degrees
% mag:      magnitude of complex number
%
%             *** see complex2angled.m ***
%             *** see angled2complex.m ***


if ~exist('nPeriod','var') || isempty(nPeriod) nPeriod = 1; end

aRad = (1./nPeriod).*angle(c);
mag  = abs(c);

