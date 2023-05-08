
% Make fake impulse response function with Gamma function (gammapdf)
% Convolving ISF with actual random walk stimulus from experiment
% End up with hypothetical tracking
% Take diff
% Cross correlate with tracking stimulus
% Should recover impulse response function




% Try adding noise to the response




% Try adding small sinusoid to the stimulus and see how that affects things






%%
signal = normrnd(0, 1, [1, 100]);
plot(signal);

%%
irf = zeros([1, 10]);
irf(3) = 1;

plot(irf);

%% 
axis = 0 : 0.2 : 2;
irf_filter = normpdf(axis, 0, 2);
plot(irf_filter)

%%
output = conv(signal, flip(irf), 'same');

figure();
plot(signal); hold on;
plot(output);

%%
output = conv(signal, flip(irf_filter), 'same');
figure();
plot(signal); hold on;
plot(output);
