function [rho pval] = circ_corrccd(alpha1deg, alpha2deg,bPLOT)

% [rho pval ts] = circ_corrcc(alpha1deg, alpha2deg)
%
%   example call: C = circ_vmrnd(pi/8,1,1000,0); N1 = circ_vmrndd(0,2,1000,0); N2 = circ_vmrndd(0,2,1000,0); 
%                 A1 = angle(exp(1i.*C) + exp(1i.*N1)).*180./pi; 
%                 A2 = angle(exp(1i.*C) + exp(1i.*N2)).*180./pi; 
%                 circ_corrccd(A1,A2,1);
% 
% circular correlation coefficient for two circular random variables in deg
%
% alpha1:	sample of angles in degrees
% alpha2:	sample of angles in degrees
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rho:      correlation coefficient
% pval:     p-value
%
% References:
%   Topics in circular statistics, S.R. Jammalamadaka et al., p. 176

% INPUT HANDLING
if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end

% CONVERT TO RADIANS
alpha1rad = alpha1deg.*pi./180; 
alpha2rad = alpha2deg.*pi./180; 

% COMPUTE CIRCULAR CORRELATION COEFFICIENT
[rho,pval]=circ_corrcc(alpha1rad,alpha2rad,0);

% PLOT STUFF
% PLOT STUFF
if bPLOT
   figure; hold on
   xlim([-180 180].*1.1); ylim([-180 180].*1.1);
   % PLOT UNITY LINE
   plot(xlim,ylim,'k--');
   % PLOT DATA POINTS
   plot(alpha1deg,alpha2deg,'ko','markersize',10,'markerface','w');
   % LABEL PLOT
   formatFigure('A1','A2',['\rho=' num2str(rho,'%.3f')]);
   set(gca,'xtick',[-180:90:180]);
   set(gca,'ytick',[-180:90:180]);
   set(gca,'xticklabel',-180:90:180);
   set(gca,'yticklabel',-180:90:180);
   axis square;
end

