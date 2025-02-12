
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SET UP WORKSPACE %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Establish paths

dataPath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Behavior/Pilot_4/';
filePath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Analysis/';

cd(dataPath)

% Load in .mat files for current subject

subj = 'KDM';

filePattern = strcat('*', subj,'*.mat');
files = dir(strcat(dataPath, filePattern));
nfiles = length(files);

% Organize into stimulus and response matrices for each SD

for f = 1:nfiles

    load(files(f).name)
    disp(files(f).name)

    % Stimulus matrix (trials,frames,sd)

    dat_stim(:,:,f) = stim;

    % Response matrix (trials,frames,sd)

    dat_resp(:,:,f) = resp;
end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% PRE-PROCESS DATA %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Wrap stimulus

dat_stim(:,:,:) = wrapTo360(dat_stim(:,:,:).*2);
dat_stim = dat_stim./2;

% Wrap response
dat_resp(:,:,:) = wrapTo360(dat_resp(:,:,:).*2);
dat_resp = dat_resp./2;

% Take derivative 

dat_stim_diff = diff(dat_stim(:,:,:),1,2);
dat_resp_diff = diff(dat_resp(:,:,:),1,2);

%%

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% IMPULSE RESPONSE FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Johannes impulse response function codue
% BurgeLabToolbox: xcorrEasy

trim_vals = 59;                                 % Values to trim off beginning of each "trial"
t = 1:1:size(dat_stim_diff,2) - trim_vals;      % Values at which time series are sampled
tMaxLag = 90;                                   % Maximum lag (in units of smpVal)
bPLOT = 0;                                      % Plot or not
bPLOTall = 0;                                   % Plot or not                  

num_cond = size(dat_stim_diff,3);

for s = 1:num_cond

    [rMU,trho,rALL,rSD] = xcorrCircEasy(dat_stim_diff(:,trim_vals+1:end,s)',dat_resp_diff(:,trim_vals+1:end,s)', t', tMaxLag, [], [], bPLOT, bPLOTall);

    % Save values

    cross_cors(s,:) = rMU;
    cross_cors_all(:,:,s) = rALL;
    cross_cors_std(s,:) = rSD;
    resp_lags(s,:) = trho;
end

% Plot stuff

figure

for s = 1:num_cond
    plot(resp_lags(s,1:tMaxLag)/60,cross_cors(s,1:tMaxLag), 'LineWidth', 1.5)
    xticks([0, 0.5, 1, 1.5, 2])
    legend('RW only', 'T = 30','T = 120')
    hold on;
end

xlabel('Time (s)') 
ylabel('Correlation value') 


% Plot stuff, but smoothed across 5 frames'LineWidth', 2.5)

figure

for s = 1:num_cond
    plot(smooth(resp_lags(s,1:tMaxLag),5)/60,smooth(cross_cors(s,1:tMaxLag),5), 'LineWidth', 1.5)
    xticks([0, 0.5, 1, 1.5, 2])
    legend('RW only', 'T = 30', 'T = 120')
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

rStdK = 1;        % Standard dev. of xcorr values at baseline
modelType = 'GMA';  % Function to fit to xcorr
initType = 'RND';   % Initialization type
bPLOT = 0;          % Plot or not
bPLOTrpt = 0;       % Plot or not

for s = 1:num_cond
    
    [rFit,rParam,rLagFit] = xcorrFitMLE(resp_lags(s,1:tMaxLag)./600,cross_cors(s,1:tMaxLag),cross_cors_std(s,1:tMaxLag),rStdK,modelType,initType,bPLOT,bPLOTrpt);

    % Save values
    
    gauss_fits(s,:) = rFit;
    gauss_fit_params(:,:,s) = rParam;
    gauss_fit_lags(s,:) = rLagFit;
end

%%



%%

% Calculating delay of impulse response function

for s = 1:num_cond
    ISF_delay(s,1) = gauss_fit_params(1,2,s)/60;
end


% Calculating peak of impulse response function

for s = 1:num_cond
    ISF_peak(s,1) = gauss_fit_params(1,1,s)/60;
end


% Calculating width of impulse response function (width at half max)
% BurgeLabToolbox: widthHalfHeightGauss

for s = 1:num_cond
    [BW, T, HHlo, HHhi] = fullWidthHalfHeight(gauss_fit_lags(s,1:tMaxLag)',gauss_fits(s,1:tMaxLag)',[]);
    ISF_width(s,1) = BW/60;
end

% Plotting across conditions

sd_list = [1:3];

figure
subplot(1,3,1)

plot(1:1:3, ISF_delay,'k--.', 'MarkerSize',20)
xlim([min(sd_list)-1,max(sd_list)+1])
xticks([sd_list(1) sd_list(2) sd_list(3)])
xticklabels({'RW only','T = 30', 'T = 120'})
xlabel('Target contrast') 
ylabel('Time to peak correlation value (s)') 

subplot(1,3,2)

plot(1:1:3, ISF_peak,'k--.', 'MarkerSize',20)
xlim([min(sd_list)-1,max(sd_list)+1])
xticks([sd_list(1) sd_list(2) sd_list(3)])
xticklabels({'RW only','T = 30','T = 120'})
xlabel('Target contrast') 
ylabel('Peak correlation value') 


subplot(1,3,3)

plot(1:1:3, ISF_width,'k--.', 'MarkerSize',20)
xlim([min(sd_list)-1,max(sd_list)+1])
xticks([sd_list(1) sd_list(2) sd_list(3)])
xticklabels({'RW only','T = 30', 'T = 120'})
xlabel('Target contrast') 
ylabel('CCG width (s)') 


%%

%%%%%%%%%%% CALCULATING ORIENTATION ERROR %%%%%%%%%%%

for s = 1:num_cond
    for t = 1:30
        Ornt_Err(t,:,s) = dat_stim(t,:,s) - dat_resp(t,:,s);
    end
end

% Plot example trace (10th "trial")

color = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250]};

for s = 1:num_cond
    figure(s)

    plot(1:1:600, Ornt_Err(10,61:end,s)/60, 'LineWidth', 2.5, 'Color', color{s})

    ylim([-2 2])
    xlabel('Time (frames)') 
    ylabel('Orientation error')
end

%%

% Plot distribution of errors

figure

cond_list = [3,2,1];
color = {[0.9290 0.6940 0.1250], [0.8500 0.3250 0.0980], [0 0.4470 0.7410]};

for s = 1:num_cond
    histogram(Ornt_Err(:,:,cond_list(s)), 'FaceAlpha', 0.3, 'FaceColor', color{s})
    xlim([-100 100])
    hold on
end

xlabel('"Trial" count') 
ylabel('Orientation error') 


% Average orientation error as a function of contrast

for s = 1:num_cond
    avg_err_full(s,:) = mean(Ornt_Err(:,:,s));
end

avg_err = abs(mean(avg_err_full,2));

figure

plot(1:1:4, avg_err,'k--.', 'MarkerSize',20)
xlim([min(sd_list)-0.5,max(sd_list)+0.5])
xticks([sd_list(1) sd_list(2) sd_list(3)])
xticklabels({'0.125','0.025','0.005'})
xlabel('Target contrast') 
ylabel('Average orientation error') 




