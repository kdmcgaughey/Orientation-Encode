%% Test our circular convolution function
n_frame = 1100;

% Random walk:
stim_RW = normrnd(0, 1, [1, n_frame]);
stim_RW = cumsum(stim_RW) + 90;

figure();
subplot(1, 2, 1);
plot(stim_RW);

subplot(1, 2, 2);
stim_wrap = wrapTo360(stim_RW);
plot(stim_wrap);

% define IRF
t = 1:100;
a = 10;
b = 2;
irf = gampdf(t, a, b);

figure()
plot(irf);

%% Convolution
y = conv(stim_RW, irf, 'full');
y = y(1:length(stim_RW));
figure();
subplot(1, 2, 1);
plot(stim_RW(100:end)); hold on;
plot(y(100:end));

%% Circular Conv
y = circ_conv(stim_RW, irf, 'full');
y = y(1:length(stim_RW));
subplot(1, 2, 2);
plot(stim_wrap); hold on;
plot(y(100:end));
