function cfg=figure05_config(cfg)
%FIGURE05_CONFIG Set representative lever arms and force-term export spacing.
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
cfg.sim.figure05.leverLengthsMm=[50,100];
cfg.sim.figure05.leverVectors_b=[1;1;1]/sqrt(3)*[0.05,0.1];

% Figure-specific experiment settings
cfg.sim.experiment.exportStride=1000;
end
