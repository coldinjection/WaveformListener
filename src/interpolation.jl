# use `interpolator` that spans from [0, 0] to [1, 1] to interpolate between [0, `from`] and [1, `to`]
interpolate(interpolator, from, to, x) = interpolator(x) * (to-from) + from
interpolate(interpolator, from, to) = x -> interpolate(interpolator, from, to, x)

_linear_intp(x) = x
_3rd_order_intp(x) = -2x^3+3x^2
_sin_intp(x) = sinpi(0.5*x)

