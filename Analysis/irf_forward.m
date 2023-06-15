function y = irf_forward(t, a, b, x)

% define the IRF as the gamma function
irf = gampdf(t, a, b);

% input stimulus
% x (num_trial, num_frames)

% convolution with the stimulus
y = zeros(size(x));
for idx = 1:size(x, 1)
    y_long = conv(x(idx, :), irf, 'full');
    y(idx, :) = y_long(1:size(x, 2));
end

end