function [Cbn,dCbn,ddCbn,wnb_b,alpha_nb_b]=attitude_inter(pp,t)
%ATTITUDE_INTER Evaluate 321 attitude matrices and analytic angular motion.
%
% Inputs
%   pp - Structure containing theta, phi, and psi splines.
%   t - N query times in s.
%
% Outputs
%   Cbn - 3-by-3-by-N body-to-navigation matrices.
%   dCbn - First matrix derivatives in 1/s.
%   ddCbn - Second matrix derivatives in 1/s^2.
%   wnb_b - N-by-3 body-relative-to-navigation rates in b, rad/s.
%   alpha_nb_b - N-by-3 component derivatives of wnb_b, rad/s^2.
%
% Related functions
%   Calls EvalSplineAll, elur2dcm, skew.
%   Called by avp_to_imu.
t=t(:);
[theta,dtheta,ddtheta]=EvalSplineAll(pp.theta,t);
[phi,dphi,ddphi]=EvalSplineAll(pp.phi,t);
[psi,dpsi,ddpsi]=EvalSplineAll(pp.psi,t);
ct=cos(theta); st=sin(theta);
cf=cos(phi); sf=sin(phi);
% Compute body angular motion using derivative ordering [phi theta psi].
wnb_b=[dphi-st.*dpsi, ...
    cf.*dtheta+sf.*ct.*dpsi, ...
    -sf.*dtheta+cf.*ct.*dpsi];
alphaP=ddphi-ct.*dtheta.*dpsi-st.*ddpsi;
alphaQ=-sf.*dphi.*dtheta+cf.*ddtheta ...
    +(cf.*dphi.*ct-sf.*st.*dtheta).*dpsi+sf.*ct.*ddpsi;
alphaR=-cf.*dphi.*dtheta-sf.*ddtheta ...
    +(-sf.*dphi.*ct-cf.*st.*dtheta).*dpsi+cf.*ct.*ddpsi;
alpha_nb_b=[alphaP,alphaQ,alphaR];
Cbn=elur2dcm(theta,phi,psi);
Omega=skew(wnb_b);
dCbn=pagemtimes(Cbn,Omega);
ddCbn=pagemtimes(Cbn,pagemtimes(Omega,Omega)+skew(alpha_nb_b));
end
