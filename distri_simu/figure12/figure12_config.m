function cfg=figure12_config(cfg)
%FIGURE12_CONFIG Provide the attitude-display configuration hook.
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
end
