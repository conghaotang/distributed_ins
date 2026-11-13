function cfg=figure02_config(cfg)
%FIGURE02_CONFIG Set heading/position interpolation interval, rate, and source spacing.
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
cfg.sim.experiment.timeRange_s=[0, 50];
cfg.sim.experiment.reconstructionHz=100;
cfg.sim.experiment.sourceExportStride=2;
end
