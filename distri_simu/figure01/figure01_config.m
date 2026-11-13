function cfg=figure01_config(cfg)
%FIGURE01_CONFIG Set attitude display duration and source export spacing.
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
cfg.sim.experiment.duration_h=24;
cfg.sim.experiment.exportStride=200;
end
