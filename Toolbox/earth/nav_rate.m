function eth=nav_rate(B,H,vn,earth)
%NAV_RATE Evaluate curvature radii, Earth rates, and gravity for one ENU state.
%
% Inputs
%   B - Geodetic latitude in rad.
%   H - Ellipsoidal height in m.
%   vn - Three-element ENU velocity in m/s.
%   earth - Earth constants and normal-gravity parameters.
%
% Outputs
%   eth - RN/RM in m, wieN/wenN as 3-by-1 rates in rad/s, and gravity magnitude g in m/s^2.
%
% Related functions
%   Calls normal_g.
%   Called by ins_step.
vn=vn(:);s=sin(B);c=cos(B);
q=1-earth.e2*s^2;

eth.RN=earth.a/sqrt(q);
eth.RM=earth.a*(1-earth.e2)/q^(3/2);
eth.wieN=[0;earth.wie*c;earth.wie*s];
eth.wenN=[-vn(2)/(eth.RM+H); ...
           vn(1)/(eth.RN+H); ...
           vn(1)*tan(B)/(eth.RN+H)];
eth.g=normal_g(B,H,earth);
end
