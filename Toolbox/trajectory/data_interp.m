function pp=data_interp(avp)
%DATA_INTERP Build six Not-a-Knot trajectory splines after unwrapping roll and yaw.
%
% Inputs
%   avp - N-by-7 [theta phi psi B L H t] with at least four increasing time nodes.
%
% Outputs
%   pp - Scalar splines theta, phi, psi, B, L, H, plus tBase and preprocessed raw channels.
%
% Related functions
%   Calls splineLeftBound, unwrap2pi.
%   Called by avp_to_imu.
%   Called by experiment main scripts.
raw=avp(:,1:6);
raw(:,2)=unwrap2pi(raw(:,2));
raw(:,3)=unwrap2pi(raw(:,3));
series=splineLeftBound(avp(:,7),raw);
fields={'theta','phi','psi','B','L','H'};
pp=struct();
for j=1:6
    pp.(fields{j})=series{j};
end
pp.tBase=avp(:,7);
pp.raw=raw;
end
