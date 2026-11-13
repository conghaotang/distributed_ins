function cfg=figure16_config(cfg)
%FIGURE16_CONFIG Configure two orthogonal IMUs and local-frame interpolation settings.
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
cfg.layout=[1 3 3 0 0 0;2 3 3 2000 -50000 4000];
% Reuse the orthogonal IMU configuration of subsequent dual-system experiments.
cfg=imu3_parameters(cfg);

% Figure-specific experiment settings
cfg.sim.experiment.timeRange_s=[0,50];
cfg.sim.experiment.sourceExportStride=2;
end
