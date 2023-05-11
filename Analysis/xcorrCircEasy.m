function [rMU,trho,rALL,rSD] = xcorrCircEasy(x,y,t,tMaxLag,scaleopt,tBgnEnd,bPLOT,bPLOTall)

% function [rMU,trho,rALL,rSD] = xcorrCircEasy(x,y,t,tMaxLag,scaleopt,tBgnEnd,bPLOT,bPLOTall)
%
%   example call:   xDeg     = [0; cumsum(randn(1000,1))]; lagInd = 50;
%                   yDeg     = [zeros(lagInd,1); xDeg(1:end-lagInd)];
%                   xDegDff  = circ_distd(xDeg(2:end),xDeg(1:end-1),2); 
%                   yDegDff  = circ_distd(yDeg(2:end),yDeg(1:end-1),2);
%                   xcorrCircEasy(xDegDff,yDegDff,linspace(0,9.99,1000),[],[],[],1);
%
% circular cross-correlation between two circular variables
% 
% x:         time series number 1 in degrees                  [ N x nTrl ]
% y:         time series number 2 in degrees                  [ N x nTrl ]
% t:         values at which time series are sampled          [ N x  1   ]
% tMaxLag:   max lags to compute in units of t
% scaleopt:  'coeff' -> normalized cross correlation (default)
% tBgnEnd:   sample values to use to compute cross correlation
%            e.g. if t equals tSec and tBgnEnd = [1 10] 
%            then time series values between 1 and 10 seconds 
%            will be used to compute the cross-correlation
% bPLOT:     plot or not
%            1 -> plot
%            0 -> not
% bPLOTall:  plot each run or not
%            1 -> plot each run
%            0 -> not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rMU:       mean cross-correlation
% trho:      values of lags (e.g. time lag in secs)
% rALL:      all  cross-correlations (for each run)
% rSD:       standard deviation of cross-correlations across repeats

% INPUT HANDLING
if ~exist('y',     'var')    || isempty(y)         y         = x;          end
if ~exist('t','var')         || isempty(t)         t    = [1:size(x,1)]';  end
if ~exist('tMaxLag','var')   || isempty(tMaxLag)   tMaxLag = size(x,1)-1;  end
if ~exist('scaleopt','var')  || isempty(scaleopt)  scaleopt  = 'coeff';    end
if ~exist('tBgnEnd','var')   || isempty(tBgnEnd)   tBgnEnd = [1 max(t)];   end
if numel(tBgnEnd) == 1,                            tBgnEnd(2) = max(t);    end
if ~exist('bPLOT','var')     || isempty(bPLOT)     bPLOT     = 0;          end
if ~exist('bPLOTall','var')  || isempty(bPLOTall)  bPLOTall  = 0;          end

% TIME SAMPLES TO USE IN COMPUTING CCG
indGd = t(:) >= tBgnEnd(1) & t(:) <= tBgnEnd(2);
% CHECK THAT INDICES ARE MATCHED TO SAMPLE
indGd = indGd(1:length(x));
% MAX LAG
maxLagSmp = find(t < tMaxLag,1,'last'); disp('xcorrCircEasy: WARNING! maxLagSmp not being used for anything... WRITE CODE to fix it?!?')

% USE ONLY INDICTES 
indBgn = find(t == tBgnEnd(1));
indEnd = find(t == tBgnEnd(end));
% 
xR = x(indBgn:indEnd,:);
yR = y(indBgn:indEnd,:);
% XCORR USING circ_corrccd.m AND A FOR LOOP 
for j = 1:size(yR,2) % LOOP OVER nTrl
    for i = 1:size(yR,1) % LOOP OVER tSec
           
        % DO IT RIGHT
        rALL(i,j)   = circ_corrccd(xR(:,j),yR(:,j));
        
        % SHIFT RESPONSES
        yR=[yR(end,:);yR(1:end-1,:)]; %circular shift
    end
end
rALL = flipud(rALL);
% MEAN XCORR
rMU = mean(rALL,2);
% STANDARD DEVIATION OF XCORR
rSD = std(rALL,[],2);
% GET TIME SAMPLES RIGHT
ind = 1:size(yR,1);
trho = t(ind);


%% XCORR USING BUILT IN MATLAB FUNCTIONS
% for i = 1:size(x,2)
% rALL(:,i)  = flipud(xcorr(x(indGd,i),y(indGd,i),maxLagSmp,scaleopt));
% end
% 
% % MEAN XCORR
% rMU = mean(rALL,2);
% % STANDARD DEVIATION OF XCORR
% rSD = std(rALL,[],2);
% % LAG VALUES
% trho = smpPos(1./diff(t(1:2)),size(rMU,1))';

if bPLOT == 1
    %%
   figure; hold on
   if bPLOTall == 1
   plot(trho,rALL,'linewidth',0.5);
   end
   plot(trho,rMU,'k','linewidth',2);
   formatFigure('Lag','Correlation');
   axis square; 
   if strcmp(scaleopt,'coeff') 
   ylim([-.25 1.05]); 
   plot([0 0],ylim,'k--');
   xlim([0 2])
   end
end