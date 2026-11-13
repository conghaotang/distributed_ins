function [imu,rw]=acc_meas(imu,cfg)
%ACC_MEAS Generate accelerometer observations with lever-arm and sensor errors.
%
% Inputs
%   imu - t is N-by-1 time (s). f, w, and wa are N-by-3 ideal body force (m/s^2), angular rate
%       (rad/s), and acceleration (rad/s^2).
%   cfg - SI err.acc fields axes (M-by-3), location (3-by-M, m), relative scale, bias, noise,
%       and randomWalk.
%
% Outputs
%   imu - Updated structure with N-by-M sensitive-axis force observations in f (m/s^2).
%   rw - M-by-1 final bias random walk in m/s^2.
%
% Related functions
%   Called by avp_to_imu.
%   Called by experiment main scripts.
err=cfg.err.acc;
dt=imu.t(2)-imu.t(1);
N=size(imu.f,1);
mu=err.axes;
M=size(mu,1);
% Use w x (w x c)=w(w dot c)-c|w|^2 and directly project onto the sensing axes.
% μ·[w×(w×c)+wa×c]
% =(μ·w)(w·c)-(μ·c)|w|^2+wa·(c×μ)。
% Evaluate all M axes together, avoiding repeated N-by-3 temporary arrays.
c=err.location;
muT=mu.';
w2=sum(imu.w.^2,2);
mc=sum(muT.*c,1);
rotAcc=(imu.w*muT).*(imu.w*c)-w2*mc+imu.wa*cross(c,muT,1);
fMeas=imu.f*muT+rotAcc;
imu.f=fMeas.*(1+err.scale(:).')+err.bias(:).';

rw=zeros(M,1);
for j=1:M
    if err.noise(j)~=0
        imu.f(:,j)=imu.f(:,j)+err.noise(j)/sqrt(dt)*randn(N,1);
    end
    if err.randomWalk(j)~=0
        rwSeries=cumsum(err.randomWalk(j)*sqrt(dt)*randn(N,1));
        imu.f(:,j)=imu.f(:,j)+rwSeries;
        rw(j)=rwSeries(end);
    end
end
end
