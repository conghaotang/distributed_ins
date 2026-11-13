function g=normal_g(B,H,earth)
%NORMAL_G Evaluate WGS-84 normal-gravity magnitude.
%
% Inputs
%   B - Geodetic latitude in rad, scalar or compatible array.
%   H - Ellipsoidal height in m, scalar or compatible array.
%   earth - Normal-gravity parameters a, e2, ge, and k.
%
% Outputs
%   g - Normal-gravity magnitude in m/s^2. ENU gravity is [0;0;-g].
%
% Related functions
%   Called by avp_to_imu, nav_rate.
s2=sin(B).^2;
g0=earth.ge.*(1+earth.k*s2)./sqrt(1-earth.e2*s2);
h=H/earth.a;
g=g0.*(1-2*h+3*h.^2);
end
