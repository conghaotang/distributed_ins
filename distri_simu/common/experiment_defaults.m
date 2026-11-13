function cfg=experiment_defaults(cfg)
%EXPERIMENT_DEFAULTS Populate experiment settings before sensor unit conversion.
%
% Inputs
%   cfg - Raw sensor and algorithm configuration.
%
% Outputs
%   cfg - Configuration with residual cases, sampling/export settings, height aiding, and
%       initialAlign in deg.
%
% Related functions
%   Called by experiment_config.
cfg.sim.experiment.reconstructionHz=cfg.fs;
cfg.sim.reconstruction.referencePoint='common_origin';
cfg.sim.calibration.residualFractions=[0,0.05,0.30];
cfg.sim.calibration.names={'Exact','Small','Large'};
cfg.sim.experiment.exportStride=1000;
cfg.sim.experiment.noiseSeed=20261021;
cfg.sim.experiment.duration_s=Inf;
cfg.sim.navigation.heightAiding=true;
cfg.err.initialAlign=zeros(3,1); % Initial misalignment angles, deg.
end
