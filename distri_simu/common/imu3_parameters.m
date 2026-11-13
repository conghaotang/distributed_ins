function cfg=imu3_parameters(cfg)
%IMU3_PARAMETERS Configure orthogonal three-axis sensors for each system.
%
% Inputs
%   cfg - Raw configuration with three gyros and three accelerometers per layout row.
%
% Outputs
%   cfg - Raw configuration with repeated identity nominal axes and the first three sensors'
%       errors and internal locations.
%
% Related functions
%   Called by figure16_config, figure17_config, figure20_config.
systemCount=size(cfg.layout,1);
for sensorCell={'gyro','acc'}
    sensor=sensorCell{1};
    cfg.err.(sensor).nominalAxes=repmat(eye(3),systemCount,1);
    for fieldCell={'directionErrorArcsec','directionErrorBearingDeg', ...
            'bias','scale','noise','randomWalk'}
        field=fieldCell{1};
        cfg.err.(sensor).(field)=repmat(cfg.err.(sensor).(field)(1:3),systemCount,1);
    end
end
cfg.err.acc.location=repmat(cfg.err.acc.location(:,1:3),1,systemCount);
end
