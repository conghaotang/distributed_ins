function cfg=figure19_config(cfg)
%FIGURE19_CONFIG Configure dual-system reconstruction and navigation.
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
%   Calls figure18_config.
%   Called by experiment main scripts.
cfg=figure18_config(cfg);
end
