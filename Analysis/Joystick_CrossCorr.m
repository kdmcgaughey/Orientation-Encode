
% Establish paths

dataPath = '/Users/karamcgaughey/Documents/GoldLab/Cont_Track_Context/Behavior/';
filePath = '/Users/karamcgaughey/Documents/GoldLab/Cont_Track_Context/Analysis/';

cd(dataPath)

% Joystick pilot data

dat_1 = readNPY("ori_track_data_KM_RW_only_std2_Joystick.npy")';    % SD = 2

% Wrap stimulus orientation

dat_stim_wrap = wrapTo360(2*(dat_1(:,1)));
dat_stim = dat_stim_wrap/2;

%%

% Separate single stim/response array into a matrix where rows are "trials"

n_frames = 660;
n_trials = length(dat_1)/n_frames;

dat_1_Stim_mat = reshape(dat_stim,[n_frames, n_trials])';
dat_1_Resp_mat = reshape(dat_1(:,2),[n_frames, n_trials])';

% Cut off the first 60 frames (1 s) from each trial

dat_1_Stim_mat_trim = dat_1_Stim_mat(:,61:end);
dat_1_Resp_mat_trim = dat_1_Resp_mat(:,61:end);

% Reshape again back to single array

% dat_1_Stim_mat_trim = dat_1_Stim_mat_trim';
% dat_1_Resp_mat_trim = dat_1_Resp_mat_trim';
% 
% dat_1_Stim_mat_trim_reshape = reshape(dat_1_Stim_mat_trim,1,[]);
% dat_1_Resp_mat_trim_reshape = reshape(dat_1_Resp_mat_trim,1,[]);

% Smoothing

% dat_1_Stim_mat_trim_reshape = smooth(dat_1_Stim_mat_trim_reshape,50);
% dat_1_Resp_mat_trim_reshape = smooth(dat_1_Resp_mat_trim_reshape,50);

% Take derivatice of stimulus and response lists

dat_1_Stim_mat_trim_diff = diff(dat_1_Stim_mat_trim,1,2);
dat_1_Resp_mat_trim_diff = diff(dat_1_Resp_mat_trim,1,2);

% Loop through each "trial"

for t = 1:n_trials

    [c,lags] = xcorr(dat_1_Resp_mat_trim_diff(t,:), dat_1_Stim_mat_trim_diff(t,:), 'coeff');

    cross_cors(t,:) = c;
    resp_lags(t,:) = lags;
end

corr_mean = mean(cross_cors);
resp_lag_mean = mean(resp_lags);

figure
plot(resp_lag_mean, corr_mean)

figure
plot(smooth(resp_lag_mean,5), smooth(corr_mean,5))


