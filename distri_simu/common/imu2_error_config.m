function cfg=imu2_error_config(cfg)
%IMU2_ERROR_CONFIG Set the second system's sensor errors and internal lever arms.
%
% Inputs
%   cfg - Raw dual-system three-axis configuration.
%
% Outputs
%   cfg - Raw configuration with system 2 errors in engineering units and internal accelerometer
%       offsets in mm.
%
% Related functions
%   Called by figure18_config.
gyroIndex=cfg.layout(1,2)+(1:cfg.layout(2,2));
accIndex=cfg.layout(1,3)+(1:cfg.layout(2,3));
cfg.err.gyro.directionErrorArcsec(gyroIndex)=[18;11;16];
cfg.err.gyro.directionErrorBearingDeg(gyroIndex)=[-35;60;120];
cfg.err.gyro.scale(gyroIndex)=[-12;8;15];
cfg.err.gyro.bias(gyroIndex)=[-0.05;0.08;-0.04];
cfg.err.gyro.noise(gyroIndex)=[0.8;0.5;0.7];
cfg.err.gyro.randomWalk(gyroIndex)=zeros(3,1);

cfg.err.acc.directionErrorArcsec(accIndex)=[16;10;14];
cfg.err.acc.directionErrorBearingDeg(accIndex)=[75;190;300];
cfg.err.acc.scale(accIndex)=[8;-15;12];
cfg.err.acc.bias(accIndex)=[-500;900;-1200];
cfg.err.acc.noise(accIndex)=[12;8;15];
cfg.err.acc.randomWalk(accIndex)=zeros(3,1);
% Reverse the previous system 2 internal lever arms while retaining their lengths and other parameters.
cfg.err.acc.location(:,accIndex)=[ ...
     35,  3, -2;
      4, 40,-38;
     -3, -5,  6];
end
