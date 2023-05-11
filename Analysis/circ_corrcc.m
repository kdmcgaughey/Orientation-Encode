function [rho,pval] = circ_corrcc(alpha1, alpha2, bPLOT)

% [rho,pval] = circ_corrcc(alpha1, alpha2, bPLOT)
%
%   example call: C = circ_vmrnd(pi/4,2,1000,0); N1 = circ_vmrnd(0,2,1000,0); N2 = circ_vmrnd(0,2,1000,0); 
%                 A1 = angle(exp(1i.*C) + exp(1i.*N1)); A2 = angle(exp(1i.*C) + exp(1i.*N2)); 
%                 circ_corrcc(A1,A2,1);
% 
% circular correlation coefficient for two circular random variables in rad
%
% alpha1:	sample of angles in radians
% alpha2:	sample of angles in radians
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rho:      correlation coefficient
% pval:     p-value
%
% References:
%   Topics in circular statistics, S.R. Jammalamadaka et al., p. 176
%
% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html
% 
% Modified by Johannes Burge, 2017
% jburge@sas.upenn.edu

% INPUT HANDLING
if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end

% INPUT CHECKING
if size(alpha1,2) > size(alpha1,1) alpha1 = alpha1'; end
if size(alpha2,2) > size(alpha2,1) alpha2 = alpha2'; end
if length(alpha1)~=length(alpha2)  error('circ_corrcc: WARNING! Input dimensions do not match'); end

% compute mean directions
n = length(alpha1);
alpha1_bar = circ_mean(alpha1);
alpha2_bar = circ_mean(alpha2);

% compute correlation coeffcient from p. 176
num = sum(sin(alpha1 - alpha1_bar) .* sin(alpha2 - alpha2_bar));
den = sqrt(sum(sin(alpha1 - alpha1_bar).^2) .* sum(sin(alpha2 - alpha2_bar).^2));
rho = num / den;	

% compute pvalue
l20 = mean( sin(alpha1 - alpha1_bar).^2);
l02 = mean( sin(alpha2 - alpha2_bar).^2);
l22 = mean((sin(alpha1 - alpha1_bar).^2) .* (sin(alpha2 - alpha2_bar).^2));

ts = sqrt((n * l20 * l02)/l22) * rho;
pval = 2 * (1 - normcdf(abs(ts)));

% PLOT STUFF
if bPLOT
   figure; hold on
   xlim([-pi pi].*1.1); ylim([-pi pi].*1.1);
   % PLOT UNITY LINE
   plot(xlim,ylim,'k--');
   % PLOT DATA POINTS
   plot(alpha1,alpha2,'ko','markersize',10,'markerface','w');
   % LABEL PLOT
   formatFigure('A1','A2',['\rho=' num2str(rho,'%.3f')]);
   set(gca,'xtick',[-pi:pi/2:pi]);
   set(gca,'ytick',[-pi:pi/2:pi]);
   set(gca,'xticklabel',{'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
   set(gca,'yticklabel',{'-\pi' '-\pi/2' '0' '\pi/2' '\pi'});
   axis square;
end
