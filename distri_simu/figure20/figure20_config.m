function cfg=figure20_config(cfg)
%FIGURE20_CONFIG Configure single-system orthogonal IMU navigation.
%
% Inputs
%   cfg - Raw sensor and experiment configuration before SI conversion. Sensor errors use the
%       engineering units defined in config.m.
%
% Outputs
%   cfg - Raw configuration with this experiment's selected settings. Unit conversion follows in
%       config_2.
%
% Related functions
%   Used as an override by experiment_config before config_2.
%   Calls imu3_parameters.
%   Called by experiment main scripts.
cfg.layout=[1 3 3 0 0 0];
cfg=imu3_parameters(cfg);
cfg.sim.reconstruction.referencePoint='system_origin';
cfg.sim.experiment.exportStride=20;
end
