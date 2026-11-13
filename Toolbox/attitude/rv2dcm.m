function C=rv2dcm(rv)
%RV2DCM Convert a rotation vector to a finite rotation matrix.
%
% Inputs
%   rv - Three-element rotation vector in rad, with direction along the rotation axis.
%
% Outputs
%   C - 3-by-3 matrix computed with Rodrigues' formula and a small-angle expansion.
%
% Related functions
%   Called by ins_cnscl, ins_step, navigation_cases.
rv=rv(:);
ang=norm(rv);
K=[0,-rv(3),rv(2); ...
   rv(3),0,-rv(1); ...
   -rv(2),rv(1),0];

if ang<1e-8
    A=1-ang^2/6+ang^4/120;
    B=0.5-ang^2/24+ang^4/720;
else
    A=sin(ang)/ang;
    B=(1-cos(ang))/ang^2;
end
C=eye(3)+A*K+B*(K*K);
end
