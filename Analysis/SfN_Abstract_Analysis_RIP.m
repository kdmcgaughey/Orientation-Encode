

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SET UP WORKSPACE %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Establish paths

dataPath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Behavior/SfN_Abstract/';
filePath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Analysis/';

cd(dataPath)

% Load in .mat files for current subject

subj = 'KDM';

filePattern = strcat('*', subj,'*.mat');
files = dir(strcat(dataPath, filePattern));
nfiles = length(files);

% Filter data

a = 6;
period_list = [30, 60, 120, 240];

% Preallocate space in matrices

n_trials = 20;
n_frames = 660;

dat_stim = nans(n_trials,n_frames,4);       % Stimulus
dat_stim_RW = nans(n_trials,n_frames,4);    % Stimulus (RW component)
dat_stim_sin = nans(n_trials,n_frames,4);   % Stimulus (sinusoid component)
dat_resp = nans(n_trials,n_frames,4);       % Response

% Organize data into stimulus and response matrices
% (n_trials, n_frames, amplitude) where amplitude = [RW only (0), 2, 3, 4, 6]

for f = 1:nfiles

    load(files(f).name)
    disp(files(f).name)

    if amplitude == 0

        dat_stim_RWOnly = stim(:,:);    % Stimulus
        dat_resp_RWOnly = resp(:,:);    % Response

    elseif amplitude == a && ismember(period,period_list)

        disp("============== ANALYZING ==============")

        idx = find(period_list == period);

        dat_stim(:,:,idx) = stim;       % Stimulus
        dat_stim_RW(:,:,idx) = rw;      % Stimulus (RW component)
        dat_stim_sin(:,:,idx) = sin;    % Stimulus (sinusoid component)
        dat_resp(:,:,idx) = resp;       % Response
    end
end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% CHECK/VISUALIZE DATA %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Visualize a few trials from each condition

% viz_trials = 9;
% num_cond = size(dat_stim,3);
% 
% for c = 1:num_cond
% 
%     figure
% 
%     for v = 1:viz_trials
% 
%         subplot(3,3,v)
% 
%         plot(dat_stim(v,:,c))
%         hold on;
% 
%         plot(dat_resp(v,:,c))
% 
%         ylabel("Orientation")
%         xlabel("Frames")
% 
%     end
% end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% PRE-PROCESS DATA %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Wrap stimulus

dat_stim_RWOnly(:,:,:) = wrapTo360(dat_stim_RWOnly(:,:,:).*2);
dat_stim_RWOnly = dat_stim_RWOnly./2;

dat_stim(:,:,:) = wrapTo360(dat_stim(:,:,:).*2);
dat_stim = dat_stim./2;

% Wrap response

dat_resp_RWOnly(:,:,:) = wrapTo360(dat_resp_RWOnly(:,:,:).*2);
dat_resp_RWOnly = dat_resp_RWOnly./2;

dat_resp(:,:,:) = wrapTo360(dat_resp(:,:,:).*2);
dat_resp = dat_resp./2;

% Take derivative 

dat_stim_diff_RWOnly = diff(dat_stim_RWOnly(:,:),1,2);
dat_resp_diff_RWOnly = diff(dat_resp_RWOnly(:,:),1,2);

dat_stim_diff = diff(dat_stim(:,:,:),1,2);
dat_resp_diff = diff(dat_resp(:,:,:),1,2);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% IMPULSE RESPONSE FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Johannes impulse response function codue
% BurgeLabToolbox: xcorrEasy

trim_vals = 59;                                 % Values to trim off beginning of each "trial"
t = 1:1:size(dat_stim_diff,2) - trim_vals;      % Values at which time series are sampled
tMaxLag = 120;                                  % Maximum lag (in units of smpVal)
bPLOT = 0;                                      % Plot or not
bPLOTall = 0;                                   % Plot or not                  


% Random walk comparison:

[rMU,trho,rALL,rSD] = xcorrCircEasy(dat_stim_diff_RWOnly(:,trim_vals+1:end)',dat_resp_diff_RWOnly(:,trim_vals+1:end)', t', tMaxLag, [], [], bPLOT, bPLOTall);

% Save values

cross_cors_RWOnly(:,:) = rMU;
cross_cors_RWOnly_all(:,:) = rALL;
cross_cors_RWOnly_std(:,:) = rSD;
resp_lags_RWOnly(:,:) = trho;


% Frequency conditions for selected amplitude:

num_cond = size(dat_stim_diff,3);

for s = 1:num_cond

    [rMU,trho,rALL,rSD] = xcorrCircEasy(dat_stim_diff(:,trim_vals+1:end,s)',dat_resp_diff(:,trim_vals+1:end,s)', t', tMaxLag, [], [], bPLOT, bPLOTall);

    % Save values

    cross_cors(s,:) = rMU;
    cross_cors_all(:,:,s) = rALL;
    cross_cors_std(s,:) = rSD;
    resp_lags(s,:) = trho;
end

%% 
% Plot stuff

figure

% Random walk comparison:

plot(resp_lags_RWOnly(1:tMaxLag)/60,cross_cors_RWOnly(1:tMaxLag), 'LineWidth', 1.5)
hold on;

% Frequency conditions for selected amplitude:

for s = 1:num_cond
    plot(resp_lags(s,1:tMaxLag)/60,cross_cors(s,1:tMaxLag), 'LineWidth', 1.5)
    xticks([0, 0.5, 1, 1.5, 2])
    legend('T = RW', 'T = 30', 'T = 60', 'T = 120', 'T = 240')
    hold on;
end

xlabel('Time (s)') 
ylabel('Correlation value') 


% Plot stuff, but smoothed across 5 frames'LineWidth', 2.5)

figure

% Random walk comparison:

plot(smooth(resp_lags_RWOnly(1:tMaxLag),5)/60,smooth(cross_cors_RWOnly(1:tMaxLag),5), 'LineWidth', 1.5)
hold on;

% Frequency conditions for selected amplitude:

for s = 1:num_cond
    plot(smooth(resp_lags(s,1:tMaxLag),5)/60,smooth(cross_cors(s,1:tMaxLag),5), 'LineWidth', 1.5)
    xticks([0, 0.5, 1, 1.5, 2])
    legend('T = RW', 'T = 30', 'T = 60', 'T = 120', 'T = 240')
    hold on;
end

xlabel('Time (s)') 
ylabel('Correlation value') 


%%

%%%%%%%%%%%%%%%%%%%%
%%%%% ANALYSIS %%%%%
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% FITTING IMPULSE RESPONSE FUNCTION %%%%%%%%%%%

% Fitting impulse response function with Gaussian distribution
% BurgeLabToolbox: xcorFitMLE

rStdK = 1;          % Standard dev. of xcorr values at baseline
modelType = 'GMA';  % Function to fit to xcorr
initType = 'RND';   % Initialization type
bPLOT = 0;          % Plot or not
bPLOTrpt = 0;       % Plot or not


% Random walk:

[rFit,rParam,rLagFit] = xcorrFitMLE(resp_lags_RWOnly(1:tMaxLag)/60,cross_cors_RWOnly(1:tMaxLag),cross_cors_RWOnly_std(1:tMaxLag),rStdK,modelType,initType,bPLOT,bPLOTrpt);

% Save values

gauss_fits_RWOnly = rFit;
gauss_fit_params_RWOnly = rParam;
gauss_fit_lags_RWOnly = rLagFit;


for s = 1:num_cond
    
    [rFit,rParam,rLagFit] = xcorrFitMLE(resp_lags(s,1:tMaxLag)./60,cross_cors(s,1:tMaxLag),cross_cors_std(s,1:tMaxLag),rStdK,modelType,initType,bPLOT,bPLOTrpt);

    % Save values
    
    gauss_fits(s,:) = rFit;
    gauss_fit_params(:,:,s) = rParam;
    gauss_fit_lags(s,:) = rLagFit;
end


%%

%%%%%%%%%%% Check fits %%%%%%%%%%%

figure; hold on;

colors = {[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880]};

% RW control:

% Data:
plot(resp_lags_RWOnly(1:tMaxLag)./60,cross_cors_RWOnly(1:tMaxLag), '--','linewidth',1, 'Color', [0 0.4470 0.7410]);

% Fit:
plot(gauss_fit_lags_RWOnly,gauss_fits_RWOnly,'-' ,'linewidth',2, 'Color', [0 0.4470 0.7410]);


for s = 1:num_cond

    xLim=minmax(resp_lags(s,1:tMaxLag)./60);

    % Data:
    plot(resp_lags(s,1:tMaxLag)./60,cross_cors(s,1:tMaxLag), '--','linewidth',1, 'Color', colors{s});

    % Fit:
    plot(gauss_fit_lags(s,:),gauss_fits(s,:),'-' ,'linewidth',2, 'Color', colors{s});
    
    legend('RW','', 'T = 30', '', 'T = 60', '','T = 120', '',  'T = 240')
end

% Format stuff:
axis square; 
xlim([-0.125 1.75]);
ylim([-0.025 0.16])

plot(xLim,[0 0],'k--','linewidth',0.5, 'HandleVisibility','off');
plot([0 0],ylim,'k--','linewidth',0.5, 'HandleVisibility','off');

%%

% Calculating width of impulse response function (width at half max)
% BurgeLabToolbox: fullWidthHalfHeight
% Frequency conditions: 

for s = 1:num_cond
    [BW, T, HHlo, HHhi] = fullWidthHalfHeight(gauss_fit_lags(s,1:tMaxLag)',gauss_fits(s,1:tMaxLag)',[]);
    ISF_width(s,1) = BW*1000;
end


% Random walk:

[BW, T, HHlo, HHhi] = fullWidthHalfHeight(gauss_fit_lags_RWOnly(1:tMaxLag),gauss_fits_RWOnly(1:tMaxLag),[]);
ISF_width(5,1) = BW*1000;



figure

plot(1:5,ISF_width, 'k-','LineWidth', 2)
xticks([1, 2, 3, 4, 5])
xlim([0,6])
xticklabels({'T = 30','T = 60','T = 120','T = 240', 'RW'})
xlabel('Sinusoid period')
ylabel("Temporal integration period (ms)")