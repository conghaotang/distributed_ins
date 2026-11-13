function [theta,phi,psi]=dcm2elur(Cbn,singularTol)
%DCM2ELUR Extract 321 Euler angles from body-to-navigation matrices.
%
% Inputs
%   Cbn - 3-by-3 or 3-by-3-by-N attitude matrices.
%   singularTol - Optional singularity tolerance, default 1e-10. Singular attitudes use phi = 0.
%
% Outputs
%   theta - N-by-1 pitch angles in rad.
%   phi - N-by-1 roll angles in rad.
%   psi - N-by-1 yaw angles in rad.
%
% Related functions
%   Called by attitude_error321, refere_sys.
if nargin<2
    singularTol=1e-10;
end
n=size(Cbn,3);
c11=reshape(Cbn(1,1,:),n,1);
c21=reshape(Cbn(2,1,:),n,1);
c31=reshape(Cbn(3,1,:),n,1);
c32=reshape(Cbn(3,2,:),n,1);
c33=reshape(Cbn(3,3,:),n,1);
ct=hypot(c11,c21);
theta=atan2(-c31,ct);
phi=atan2(c32,c33);
psi=atan2(c21,c11);
singular=ct<singularTol;
phi(singular)=0;
c12=reshape(Cbn(1,2,:),n,1);
c22=reshape(Cbn(2,2,:),n,1);
psi(singular)=atan2(-c12(singular),c22(singular));
end
