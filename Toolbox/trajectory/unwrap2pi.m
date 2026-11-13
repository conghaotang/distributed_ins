function alphaUnw = unwrap2pi(alpha)
%UNWRAP2PI Unwrap periodic angles by accumulating principal-value changes.
%
% Inputs
%   alpha - N-element row or column vector in rad, with adjacent true changes below pi.
%
% Outputs
%   alphaUnw - Continuous angle sequence with the input shape, units, and first value.
%
% Related functions
%   Called by data_interp, unwrapEuler.
wasRow=isrow(alpha);a=alpha(:);
d=diff(a);
d=d-2*pi*round(d/(2*pi));
alphaUnw=a(1)+[0;cumsum(d)];
if wasRow,alphaUnw=alphaUnw.';end
end
