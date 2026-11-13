function [imu,rw]=gyro_meas(imu,cfg)
%GYRO_MEAS Generate sensitive-axis gyro observations with sensor errors.
%
% Inputs
%   imu - t is N-by-1 uniformly sampled time (s), and w is N-by-3 ideal body rate (rad/s).
%   cfg - SI err.gyro fields axes, relative scale, bias, noise, and randomWalk.
%
% Outputs
%   imu - Updated structure with N-by-M gyro observations in w (rad/s).
%   rw - M-by-1 final bias random walk in rad/s.
%
% Related functions
%   Called by avp_to_imu.
%   Called by experiment main scripts.
err=cfg.err.gyro;
dt=imu.t(2)-imu.t(1);
N=size(imu.w,1);
% Project N-by-3 body rates onto M sensing axes to produce N-by-M observations.
mu=err.axes;
M=size(mu,1);
wAxis=imu.w*mu.';
imu.w=wAxis.*(1+err.scale(:).')+err.bias(:).';

rw=zeros(M,1);
for k=1:M
    if err.noise(k)~=0
        imu.w(:,k)=imu.w(:,k)+err.noise(k)/sqrt(dt)*randn(N,1);
    end
    if err.randomWalk(k)~=0
        rwSeries=cumsum(err.randomWalk(k)*sqrt(dt)*randn(N,1));
        imu.w(:,k)=imu.w(:,k)+rwSeries;
        rw(k)=rwSeries(end);
    end
end
end
