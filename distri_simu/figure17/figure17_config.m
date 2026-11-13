function cfg=figure17_config(cfg)
%FIGURE17_CONFIG Configure dual orthogonal IMUs and system-origin reconstruction.
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
%   Called by figure18_config.
%   Called by experiment main scripts.
cfg.layout=[1 3 3 0 0 0;2 3 3 2000 -50000 4000];
cfg=imu3_parameters(cfg);
cfg.sim.reconstruction.referencePoint='system_origin';
cfg.sim.experiment.exportStride=20;
end
