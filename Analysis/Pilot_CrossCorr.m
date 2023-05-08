
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SET UP WORKSPACE %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Establish paths

dataPath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Behavior/Pliot/';
filePath = '/Users/karamcgaughey/Documents/GoldLab/Orientation_Tracking/Analysis/';

cd(dataPath)

% Load in .mat files for current subject

subj = 'LQZ';

filePattern = strcat('*', subj,'*.mat');
files = dir(strcat(dataPath, filePattern));
nfiles = length(files);

% Organize into stimulus and response matrices for each SD

mode = 'joystick';

for f = 1:nfiles

    load(files(f).name)

    if contains(files(f).name,mode)

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
dat_stim(:,:,:) = dat_stim(:,:,:)./2;

% Wrap response

dat_resp(:,:,:) = wrapTo360(dat_resp(:,:,:).*2);
dat_resp(:,:,:) = dat_resp(:,:,:)./2;

% Remove the first second

dat_stim_trim(:,:,:) = dat_stim(:,60:end,:);
dat_resp_trim(:,:,:) = dat_resp(:,60:end,:);

% Take derivative 

dat_stim_diff = diff(dat_stim_trim(:,:,:),1,2);
dat_resp_diff = diff(dat_resp_trim(:,:,:),1,2);


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% INPULSE RESPONSE FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cross correlate response and stimulus

num_cond = size(dat_stim_diff,3);
n_trials = size(dat_stim_diff,1);

for s = 1:num_cond

    for t = 1:n_trials
        [c,lags] = xcorr(dat_resp_diff(t,:,s), dat_stim_diff(t,:,s), 'coeff');
    
        cross_cors(t,:,s) = c;
        resp_lags(t,:,s) = lags;
    end

    corr_mean(s,:) = mean(cross_cors(:,:,s));
    resp_lag_mean(s,:) = mean(resp_lags(:,:,s));

end

% Plot stuff

figure

for s = 1:num_cond
    plot(resp_lag_mean(s,:),corr_mean(s,:))
    hold on;
end

% Plot stuff

figure

for s = 1:num_cond
    plot(smooth(resp_lag_mean(s,:),5),smooth(corr_mean(s,:),5))
    hold on;
end

%%

%%%%%%%%%%%%%%%%%%%%
%%%%% ANALYSIS %%%%%
%%%%%%%%%%%%%%%%%%%%


% Calculating the delay of the impulse response function




% Fitting impulse response function with Gaussian distribution





% Calculating width of impulse response function (width at half max)




% Plotting across conditions


