%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST BED TO EXAMINE CIRCULAR VS LINEAR CORRELATION COEFFS FOR       %
%           SUM OF VON MISES DISTRIBUTED RANDOM VARIABLES             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOISE AND SIGNAL CONCENTRATION PARAMETER (KAPPA ~= 1/VARIANCE)
KW = .5.*[.5 1 2 4 8 16 32];     % KAPPA PARAM OF VON MISES: NOISE
KZ = .25.*[4*ones(1,numel(KW))]; % KAPPA PARAM OF VON MISES: SIGNAL

% MEAN OF NOISE AND SIGNAL
muW = 0;
muZ = [0:pi/4:pi]; 

% NUMBER OF SAMPLES
numSmp = 10000;

% HISTOGRAM BINS
[edg ctr]=histCircEdges([-pi pi],91);
for m = 1:length(muZ) 
    
    for i = 1:length(KW), 
        % RANDOM NOISE SAMPLES
        W1 = circ_vmrnd(muW,   KW(i),numSmp); 
        W2 = circ_vmrnd(muW,   KW(i),numSmp); 
        % RANDOM SIGNAL SAMPLES
        Z  = circ_vmrnd(muZ(m),KZ(i),numSmp); 

        % SUM OF CORRELATED AND UNCORRELATED RANDOM ANGULAR VARIABLES
        X1 = mod(complex2angle(  angle2complex(Z).*angle2complex(W1) ),2*pi)-pi;
        X2 = mod(complex2angle(  angle2complex(Z).*angle2complex(W2) ),2*pi)-pi;

        % CIRCULAR CORRELATION COEFFICIENT
        rhoCrc(i) = circ_corrcc(X1,X2);
        %  LINEAR  CORRELATION COEFFICIENT
        rhoLnr(i) = corr(X1,X2);
    
        % PLOT STUFF
        figure('position',[560   133   525   815])
        subplot(3,3,1); 
        hist(W1,ctr); formatFigure([],[],'W1')
        subplot(3,3,2); 
        hist(Z,ctr); formatFigure([],[],'Z')
        subplot(3,3,3); 
        hist(W2,ctr); formatFigure([],[],'W2')
        subplot(3,3,[4:9]); hold on;
        ind = randsample(numel(X1),5000);
        h = plot(X1,X2,'k.'); % ,'markerfacecolor','k');
        formatFigure('X1=Z+W1','X2=Z+W2',['\mu_Z=' num2str(muZ(m)) ',\alpha=' num2str(KW(i)./KZ(i))]);
        axis(pi*[-1 1 -1 1])
        %%
    %     hMarker=h.MarkerHandle;
    %     hMarker.FaceColorData=uint8([0 0 0 2]');
    %     hMarker.EdgeColorData=uint8([0 0 0 2]');
    end

    figure('position',[1106         536         560         420]); 
    plot(KW./KZ,rhoCrc,'bo-',KW./KZ,rhoLnr,'rs-','linewidth',2)
    set(gca,'xscale','log'); set(gca,'xtick',KW./KZ);
    formatFigure(['\alpha (\kappa_W/\kappa_Z)'],'Correlation',['\mu_Z=' num2str(muZ(m)) ', \kappa_Z=' num2str(KZ(1))]);
    xlim(minmax(KW./KZ)); ylim([0 1]);
    axis square;
    legend({'Circular Correlation','Linear Correlation'},'Location','SouthEast')
end