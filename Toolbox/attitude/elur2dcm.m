function Cbn=elur2dcm(theta,phi,psi)
%ELUR2DCM Construct body-to-navigation matrices from 321 Euler angles.
%
% Inputs
%   theta - Pitch in rad, scalar or N-element vector.
%   phi - Roll in rad, same number of elements as theta.
%   psi - Yaw in rad, same number of elements as theta.
%
% Outputs
%   Cbn - 3-by-3-by-N matrices satisfying v_n = Cbn*v_b.
%
% Related functions
%   Called by attitude_inter.
theta=theta(:); phi=phi(:); psi=psi(:);
ct=cos(theta); st=sin(theta);
cf=cos(phi); sf=sin(phi);
cp=cos(psi); sp=sin(psi);
Cbn=zeros(3,3,numel(theta));
Cbn(1,1,:)=ct.*cp;
Cbn(2,1,:)=ct.*sp;
Cbn(3,1,:)=-st;
Cbn(1,2,:)=sf.*st.*cp-cf.*sp;
Cbn(2,2,:)=sf.*st.*sp+cf.*cp;
Cbn(3,2,:)=sf.*ct;
Cbn(1,3,:)=cf.*st.*cp+sf.*sp;
Cbn(2,3,:)=cf.*st.*sp-sf.*cp;
Cbn(3,3,:)=cf.*ct;
end
