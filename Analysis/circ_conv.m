function c = circ_conv(a, b, shape)

% Convolve a circular variable a with a linear conv kernel b

% compute the sin and cos component
a_sin = sind(a);
a_cos = cosd(a);

% linear conv with the sin and cos component
a_sin_conv = conv(a_sin, b, shape);
a_cos_conv = conv(a_cos, b, shape);

% get the angle back with arc tan function
c = atan2d(a_sin_conv, a_cos_conv);

end