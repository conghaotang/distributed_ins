function cfg=experiment_config(configOverride)
%EXPERIMENT_CONFIG Assemble shared experiment settings and raw configuration overrides.
%
% Inputs
%   configOverride - Optional function handle receiving and returning raw cfg before sensor unit
%       conversion.
%
% Outputs
%   cfg - SI configuration with residual cases, random seed, export/duration settings, height
%       aiding, and initialAlign in rad.
%
% Related functions
%   Calls config, experiment_defaults.
%   Called by demo_config.
%   Called by experiment main scripts.
if nargin==0
    cfg=config(@experiment_defaults);
else
    cfg=config(@(raw) configOverride(experiment_defaults(raw)));
end
cfg.err.initialAlign=cfg.err.initialAlign*cfg.unit.deg;
end
