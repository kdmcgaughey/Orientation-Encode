%% Test our circular convolution function
n_frame = 1100;

% Random walk:
stim_RW = normrnd(0, 3, [1, n_frame]);
stim_RW = cumsum(stim_RW) + 180;

% Sinusoid:
p = 30;
a = 20;
t = 1:1:n_frame;
h = a*sin(mod(t,p)*(2*pi/p));

stim_RW = stim_RW + h;

figure();
subplot(1, 2, 1);
plot(stim_RW);

subplot(1, 2, 2);
stim_wrap = wrapTo360(stim_RW * 2) / 2;
plot(stim_wrap);

% define IRF
t = 1:100;
a = 10;
b = 2;
irf = gampdf(t, a, b);

figure()
plot(irf);

%% Convolution
y1 = conv(stim_RW, irf, 'full');
y1 = y1(1:length(stim_RW));
figure();
subplot(1, 2, 1);
plot(stim_RW(100:end)); hold on;
plot(y1(100:end));

%% Circular Conv
y2 = wrapTo360(circ_conv(stim_RW * 2, irf, 'full')) / 2;
y2 = y2(1:length(stim_RW));
subplot(1, 2, 2);
plot(stim_wrap(100:end)); hold on;
plot(y2(100:end));

%% Simulate
y = irf_forward_circ(t, a, b, stim_wrap * 2) / 2;
y = y + normrnd(0, 2, size(y));

figure();
plot(stim_wrap); hold on;
plot(y);

%% Convert
x = stim_wrap * 2;
y = wrapTo360(y * 2);

figure();
plot(x); hold on;
plot(y);

%% Fit IRF
loss = @(para) irf_loss_circ(x, y, t, para(1), para(2));

options = optimoptions('fmincon', 'Display', 'iter');
estimate = fmincon(loss, [1, 1], [], [], [], [], [1e-3, 1e-3], [], [], options);
