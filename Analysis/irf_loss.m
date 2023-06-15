function mse = irf_loss(x, y, t, a, b)
y_hat = irf_forward(t, a, b, x);
mse = sum((y - y_hat) .^ 2, 'all') / size(x, 1);
end