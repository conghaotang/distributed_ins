function [val,d1,d2] = EvalSplineAll(pp,tEval)
%EVALSPLINEALL Evaluate a cubic spline and its first two analytic derivatives.
%
% Inputs
%   pp - Scalar MATLAB piecewise polynomial.
%   tEval - Scalar, row, or column query times in the spline's time unit.
%
% Outputs
%   val - Spline values with the same shape as tEval.
%   d1 - First derivatives in data units per time unit.
%   d2 - Second derivatives in data units per squared time unit.
%
% Related functions
%   Called by attitude_inter, avp_to_imu.
%   Called by experiment main scripts.
[breaks,coefs]=unmkpp(pp);

pp1=mkpp(breaks,coefs(:,1:3).*[3 2 1]);
pp2=mkpp(breaks,coefs(:,1:2).*[6 2]);
val=ppval(pp,tEval);
d1=ppval(pp1,tEval);
d2=ppval(pp2,tEval);
end
