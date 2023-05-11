function c = angle2complex(aRad,nPeriod)

% function c = angle2complex(aRad,nPeriod)
% 
%   example call: angle2complex(pi/4)
%
% convert angle in radians to complex number
%
% aRad:     angle in radians
% nPeriod:  period of angles (i.e. [0 180) has nPeriod = 2)
% %%%%%%%%%%%%%%
% c:        complex number of magnitude 1.0
%
%            *** see angled2complex.m ***

if ~exist('nPeriod','var') || isempty(nPeriod) nPeriod = 1; end

c = exp(1i.*(aRad.*nPeriod));

