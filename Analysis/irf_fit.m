%% Run some simulated data

%% input x
n_frame = 1000;
for i = 1:10

    % Random walk:
    stim_RW = normrnd(0, 3, [1, n_frame]);
    stim_RW = cumsum(stim_RW);

    x_rw(i,:) = stim_RW;
       
    % Sinusoid:
    
    p = 30;
    a = 20;
    t = 1:1:n_frame;
    h = a*sin(mod(t,p)*(2*pi/p));
    
    x_sin(i,:) = h;
end

x = x_rw;

%% simulate the output y
t = 1:100;
a = 10;
b = 2;

y = irf_forward(t, a, b, x);
y = y + normrnd(0, 1, size(y));

% do some plots
figure();
plot(x(10, :)); hold on;
plot(y(10, :));

%% Fit IRF
loss = @(para) irf_loss(x, y, t, para(1), para(2));

options = optimoptions('fmincon', 'Display', 'iter');
estimate = fmincon(loss, [1, 1], [], [], [], [], [1e-3, 1e-3], [], [], options);

%% Plot IRF
true_irf = gampdf(t, a, b);
est_irf = gampdf(t, estimate(1), estimate(2));

figure();
plot(true_irf); hold on;
plot(est_irf);
