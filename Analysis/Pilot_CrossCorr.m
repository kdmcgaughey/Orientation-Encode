
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SET UP WORKSPACE %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Establish paths

dataPath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Behavior/Pilot_2/';
filePath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Analysis/';

cd(dataPath)

% Load in .mat files for current subject

subj = 'KDM';

filePattern = strcat('*', subj,'*joystick.mat');
files = dir(strcat(dataPath, filePattern));
nfiles = length(files);

% Organize into stimulus and response matrices for each SD

resp_mode = 'joystick';
sd_list = [2,3,4,5];

for f = 1:nfiles

    load(files(f).name)

    if contains(files(f).name,resp_mode)

        disp(files(f).name)

        % Stimulus matrix (trials,frames,sd)

        dat_stim(:,:,sd) = stim;
    
        % Response matrix (trials,frames,sd)

        dat_resp(:,:,sd) = resp;
    end
end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% PRE-PROCESS DATA %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Wrap stimulus

dat_stim(:,:,:) = wrapTo360(dat_stim(:,:,:).*2);
%dat_stim(:,:,:) = dat_stim(:,:,:)./2;

% Wrap response

dat_resp(:,:,:) = wrapTo360(dat_resp(:,:,:).*2);
%dat_resp(:,:,:) = dat_resp(:,:,:)./2;

% Take derivative 

dat_stim_diff = diff(dat_stim(:,:,:),1,2);
dat_resp_diff = diff(dat_resp(:,:,:),1,2);


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% VISUALIZE SOME DATA %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_trials = size(dat_stim_diff,1);
cond = 5;

figure

for t = 1:10

    % Plot stimulus as a function of frame

    plot(dat_stim(t,:,cond),'-', 'LineWidth', 2, 'Color', 'k')
    hold on;

    % Plot response as a function of frame

    plot(dat_resp(t,:,cond), '--', 'LineWidth', 2, 'Color', 'r')

    % Label stuff
    
    title(['Stimulus and response (' resp_mode, ')'])
    xlabel('Frames') 
    ylabel('Orientation') 
    legend('Stimulus','Response')

    pause
    clf
end

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

for s = 5
    
    [rFit,rParam,rLagFit] = xcorrFitMLE(resp_lags(s,1:tMaxLag),cross_cors(s,1:tMaxLag),cross_cors_std(s,1:tMaxLag),rStdK,modelType,initType,bPLOT,bPLOTrpt);

    % Save values
    
    gauss_fits(s,:) = rFit;
    gauss_fit_params(:,:,s) = rParam;
    gauss_fit_lags(s,:) = rLagFit;
end

%%

% Calculating delay of impulse response function

for s = 2:5 %1:num_cond
    ISF_delay(s,1) = gauss_fit_params(1,2,s)/60;
end

% Calculating width of impulse response function (width at half max)
% BurgeLabToolbox: widthHalfHeightGauss

for s = 2:5 %1:num_cond
    [BW, T, HHlo, HHhi] = fullWidthHalfHeight(gauss_fit_lags(s,1:tMaxLag)',gauss_fits(s,1:tMaxLag)',[]);
    ISF_width(s,1) = BW/60;
end

% Plotting across conditions

figure
subplot(1,2,1)

plot(2:1:5, ISF_delay(2:end),'k--.', 'MarkerSize',30)
xlim([min(sd_list)-1,max(sd_list)+1])
xticks([sd_list(1) sd_list(2) sd_list(3) sd_list(4)])
xlabel('Random walk standard deviation (deg/frame)') 
ylabel('Impulse response function delay (s)') 


subplot(1,2,2)

plot(2:1:5, ISF_width(2:end),'k--.', 'MarkerSize',30)
xlim([min(sd_list)-1,max(sd_list)+1])
xticks([sd_list(1) sd_list(2) sd_list(3) sd_list(4)])
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

    title(['Impulse response function w/ Gaussian fit for SD = ', num2str(sd_list(s)), ' (', resp_mode, ')'])
    xlabel('Seconds') 
    ylabel('xcorr') 

end



