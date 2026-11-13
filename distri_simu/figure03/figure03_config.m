function cfg=figure03_config(cfg)
%FIGURE03_CONFIG Set angular-motion interpolation rate and export spacing.
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
%   Called by experiment main scripts.
cfg.sim.experiment.reconstructionHz=100;
cfg.sim.experiment.exportStride=1000;
end
