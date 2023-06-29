function circ_mse = irf_loss_circ(x, y, t, a, b)
y_hat = irf_forward_circ(t, a, b, x);
circ_mse = -sum(cosd(y - y_hat));
end