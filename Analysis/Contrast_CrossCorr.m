%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SET UP WORKSPACE %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Establish paths

dataPath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Behavior/Pilot_2/';
filePath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Analysis/';

cd(dataPath)

% Load in .mat files for current subject

load('12_05_2023_11_31_KDM_SD_3_joystick.mat')

dat_stim(:,:,1) = stim;
dat_resp(:,:,1) = resp;

load('12_05_2023_11_41_KDM_SD_3_joystick_lowcontrast.mat')

dat_stim(:,:,2) = stim;
dat_resp(:,:,2) = resp;

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% IMPULSE RESPONSE FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Johannes impulse response function code
% BurgeLabToolbox: xcorrEasy

trim_vals = 59;                                 % Values to trim off beginning of each "trial"
t = 1:1:size(dat_stim_diff,2) - trim_vals;      % Values at which time series are sampled
tMaxLag = 120;                                  % Maximum lag (in units of smpVal)
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
    %plot(resp_lags(s,:)/60, cross_cors(s,:))
    plot(resp_lags(s,1:tMaxLag)/60,cross_cors(s,1:tMaxLag))
    xticks([0, 0.5, 1, 1.5, 2])
    hold on;
end

% Plot stuff, but smoothed across 5 frames

figure

for s = 1:num_cond
    plot(smooth(resp_lags(s,1:tMaxLag),5)/60,smooth(cross_cors(s,1:tMaxLag),5))
    xticks([0, 0.5, 1, 1.5, 2])
    %ylim([-0.02 0.12])
    hold on;
end

%%

%%%%%%%%%%%%%%%%%%%%
%%%%% ANALYSIS %%%%%
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% FITTING IMPULSE RESPONSE FUNCTION %%%%%%%%%%%

% Fitting impulse response function with Gaussian distribution
% BurgeLabToolbox: xcorFitMLE

rStdK = 1.5;        % Standard dev. of xcorr values at baseline
modelType = 'LGS';  % Function to fit to xcorr
initType = 'RND';   % Initialization type
bPLOT = 0;          % Plot or not
bPLOTrpt = 0;       % Plot or not

for s = 1:num_cond
    
    [rFit,rParam,rLagFit] = xcorrFitMLE(resp_lags(s,1:tMaxLag),cross_cors(s,1:tMaxLag),cross_cors_std(s,1:tMaxLag),rStdK,modelType,initType,bPLOT,bPLOTrpt);

    % Save values
    
    gauss_fits(s,:) = rFit;
    gauss_fit_params(:,:,s) = rParam;
    gauss_fit_lags(s,:) = rLagFit;
end

%%

% Calculating delay of impulse response function

for s = 1:num_cond
    ISF_delay(s,1) = gauss_fit_params(1,2,s)/60;
end

% Calculating width of impulse response function (width at half max)
% BurgeLabToolbox: widthHalfHeightGauss

for s = 1:num_cond
    [BW, T, HHlo, HHhi] = fullWidthHalfHeight(gauss_fit_lags(s,1:tMaxLag)',gauss_fits(s,1:tMaxLag)',[]);
    ISF_width(s,1) = BW/60;
end

% Plotting across conditions

figure
subplot(1,2,1)

plot(1:1:2, ISF_delay,'k--.', 'MarkerSize',30)
xlim([min(sd_list)-1,max(sd_list)+1])
xticks([sd_list(1) sd_list(2)])
xlabel('Random walk standard deviation (deg/frame)') 
ylabel('Impulse response function delay (s)') 


subplot(1,2,2)

plot(1:1:2, ISF_width,'k--.', 'MarkerSize',30)
xlim([min(sd_list)-1,max(sd_list)+1])
xticks([sd_list(1) sd_list(2)])
xlabel('Random walk standard deviation (deg/frame)') 
ylabel('Impulse response function width (s)') 


%%

%%%%%%%%%%% Check Gaussian fits %%%%%%%%%%%

for s = 1:num_cond

    figure

    plot(resp_lags(s,1:tMaxLag)/60,cross_cors(s,1:tMaxLag))
    xticks([0, 0.5, 1, 1.5, 2])
    hold on

    plot(gauss_fit_lags(s,1:tMaxLag)/60,gauss_fits(s,1:tMaxLag), 'LineWidth',2)
    xticks([0, 0.5, 1, 1.5, 2])

    %title(['Impulse response function w/ Gaussian fit for SD = ', num2str(sd_list(s)), ' (', resp_mode, ')'])
    xlabel('Seconds') 
    ylabel('xcorr') 

end
