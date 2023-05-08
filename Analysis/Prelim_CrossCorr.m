
% Establish paths

dataPath = '/Users/karamcgaughey/Documents/GoldLab/Cont_Track_Context/Behavior/';
filePath = '/Users/karamcgaughey/Documents/GoldLab/Cont_Track_Context/Analysis/';

cd(dataPath)

% Load in .npy files for each run
% readNPY.m (which I stole from The Internet) needs to be on path

dat_1 = readNPY("ori_track_data_KDM_RW_only_std1.npy")';    % SD = 1
dat_2 = readNPY("ori_track_data_KDM_RW_only_std2.npy")';    % SD = 2
dat_3 = readNPY("ori_track_data_KDM_RW_only_std3.npy")';    % SD = 3
dat_4 = readNPY("ori_track_data_KDM_RW_only_std4.npy")';    % SD = 4

% Collect data into a matrix

dat(:,:,1) = dat_1;
dat(:,:,2) = dat_2;
dat(:,:,3) = dat_3;
dat(:,:,4) = dat_4;

%%

% Take derivatice of stimulus and response lists

num_ses = 4;
n_frames = 600;
n_trials = length(dat_1)/n_frames;

for d = 1:num_ses

    this_dat = dat(:,:,d);

    % Wrap stimulus

    this_dat(:,1) = wrapTo360(this_dat(:,1)*2);
    this_dat(:,1) = this_dat(:,1)/2;

    % Wrap response

    this_dat(:,2) = wrapTo360(this_dat(:,2)*2);
    this_dat(:,2) = this_dat(:,2)/2;

    % Get things reshaped by "trial"

    dat_Stim_mat(:,:,d) = reshape(this_dat(:,1),[n_frames, n_trials])';
    dat_Resp_mat(:,:,d) = reshape(this_dat(:,2),[n_frames, n_trials])';

    % Remove the first second

    dat_Stim_mat_trim(:,:,d) = dat_Stim_mat(:,60:end,d);
    dat_Resp_mat_trim(:,:,d) = dat_Resp_mat(:,60:end,d);

    % Take the difference of stimulus and response matrices

    dat_Stim_mat_diff(:,:,d) = diff(dat_Stim_mat_trim(:,:,d),1,2);
    dat_Resp_mat_diff(:,:,d) = diff(dat_Resp_mat_trim(:,:,d),1,2);

end

%% 

% Looping through each "trial"
% Take cross correlation of response and stimulus vectors


for d = 1:num_ses

    for t = 1:n_trials
        [c,lags] = xcorr(dat_Resp_mat_diff(t,:,d), dat_Stim_mat_diff(t,:,d), 'coeff');
    
        cross_cors(t,:,d) = c;
        resp_lags(t,:,d) = lags;
    end

    corr_mean(d,:) = mean(cross_cors(:,:,d));
    resp_lag_mean(d,:) = mean(resp_lags(:,:,d));

end


%%

% Plot stuff

figure

for d = 1:num_ses
    plot(smooth(resp_lag_mean(d,:),5),smooth(corr_mean(d,:),5))
    hold on;
end