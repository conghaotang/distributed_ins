function [phim,dvbm]=ins_cnscl(imuInc)
%INS_CNSCL Combine angular and velocity increments with coning/sculling compensation.
%
% Inputs
%   imuInc - Ns-by-6 increments for 1 <= Ns <= 6, ordered [dtheta_x dtheta_y dtheta_z dv_x dv_y
%       dv_z], in rad and m/s.
%
% Outputs
%   phim - 3-by-1 compensated equivalent rotation vector in rad.
%   dvbm - 3-by-1 compensated velocity increment in m/s.
%
% Related functions
%   Calls rv2dcm.
%   Called by ins_step.
nn=size(imuInc,1);
assert(size(imuInc,2)==6 && nn>=1 && nn<=6, ...
    'dins:SubsampleCount','Increments must be an N-by-6 matrix with one to six rows.');

wm=imuInc(:,1:3);
vm=imuInc(:,4:6);
wmm=sum(wm,1);
vmm=sum(vm,1);
if nn==1
    phim=wmm.';
    dvbm=rv2dcm(0.5*phim)*vmm.';
    return;
end

cs=[ ...
    2/3,       0,         0,         0,          0; ...
    9/20,      27/20,     0,         0,          0; ...
    54/105,    92/105,    214/105,   0,          0; ...
    250/504,   525/504,   650/504,   1375/504,   0; ...
    2315/4620, 4558/4620, 7296/4620, 7834/4620, 15797/4620];
coef=cs(nn-1,1:nn-1);
cm=coef*wm(1:end-1,:);
sm=coef*vm(1:end-1,:);
dphim=cross(cm,wm(end,:));
scull=cross(cm,vm(end,:))+cross(sm,wm(end,:));
rotm=0.5*cross(wmm,vmm);

phim=(wmm+dphim).';
% The second-order rotation of the accumulated velocity increment is
% required by the multi-sub-sample coning/sculling model.  Omitting this
% term leaves an O((omega*T)^2) force projection error that appears as a
% false accelerometer scale factor during rotating static tests.
rotm2=(1/6)*cross(phim,cross(phim,vmm.')).';
dvbm=(vmm+rotm+rotm2+scull).';
end
