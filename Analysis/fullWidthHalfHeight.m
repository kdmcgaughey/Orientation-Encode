function [BW T HHlo HHhi] = fullWidthHalfHeight(X,Y,bPLOT)

% function [bandwidth tuning] = fullWidthHalfHeight(X,Y,bPLOT)
%
%   example call:
%
% find bandwidth and tuning of function non-parametric amplitude spectrum
%
% X:   x values at which function is defined          [nx1]
% Y:   y values at corresponding x values             [nxm]
%%%%%%%%%%%%%%%%%%%%
% BW:   bandwidth (full width at half height)
% T:    tuning    (peak of function)
% HHlo: tuning    (low half height)
% HHhi: tuning    (high half height)

if ~exist('bPLOT','var') || isempty(bPLOT)
   bPLOT = 0; 
end
    
Xinterp = linspace(min(X),max(X),100000)';
Yinterp = interp1(X,Y,Xinterp,'spline');

for i = 1:size(Y,2)
    indMax(i,1) = find(Yinterp(:,i)==max(Yinterp(:,i)),1);    % max of peak
    T(i,1)      = Xinterp(indMax(i));                         % peak of function
    E           = abs(Yinterp(:,i)-0.5*Yinterp(indMax(i),i)); % abs(E) between function and function half height 
    indHHlo     = find(E==min(E(1:indMax(i))),1);             % index of low 
    indHHhi     = find(E==min(E(indMax(i):end)),1);           % index of low 
    HHlo(i)     = Xinterp(indHHlo);                           % half-height lo 
    HHhi(i)     = Xinterp(indHHhi);                           % half-height hi
    BW(i,1)     = HHhi(i) - HHlo(i) ;                         % bandwidth
    if indHHlo == 1 || indHHhi == length(Xinterp)
       BW(i,1) = NaN;
       disp(['fullWidthHalfHeight: WARNING! bandwidth not computable for function #' num2str(i) ]);
    else
        killer = 1;
    end
end

if bPLOT
%     figure;
%     plot(Xinterp,Yinterp,'linewidth',2)
%     formatFigure('X','Y');
    figure(777);
    set(gcf,'position',[1304         723         460         361]); hold on
    plot(abs(T(T<=0)),BW(T<=0),'kd','markerface','k','markersize',10,'linewidth',2);
    plot(T(T>=0),BW(T>=0),'ks','markerface','w','markersize',10,'linewidth',2);
    formatFigure('Tuning','Bandwidth');
    axis square
    axis([-1 16 -1 16])
    indGood = find(~isnan(T) & ~isnan(BW));
    p = [abs(T(indGood)) ones(size(indGood))]\BW(indGood);
    plot(xlim,p(1).*xlim + p(2),'k--');
    writeText(.1,.9,{['y=' num2str(p(1),3) 'x+' num2str(p(2),3) ]},'ratio',15)
    set(gca,'xtick',[0:5:15])
    set(gca,'ytick',[0:5:15])
end