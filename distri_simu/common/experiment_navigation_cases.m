function result=experiment_navigation_cases(measurement,reference,cfg)
%EXPERIMENT_NAVIGATION_CASES Select navigation states for experiment plotting and export.
%
% Inputs
%   measurement - Full-rate t/gyro/acc observations.
%   reference - Main-origin and subsystem reference states.
%   cfg - SI experiment configuration including exportStride and dt.
%
% Outputs
%   result - Per-system id, t, caseNames, residualFractions, and Nout-by-3-by-C attitudeError
%       (rad), velocityError (m/s), and positionError (m).
%
% Related functions
%   Calls navigation_cases.
%   Called by experiment main scripts.
raw=navigation_cases(measurement,reference,cfg);
result=struct();
for s=1:numel(raw.system)
    current=struct();
    current.id=raw.system(s).id;
    current.caseNames=cfg.sim.calibration.names;
    current.residualFractions=cfg.sim.calibration.residualFractions;
    navTime=raw.system(s).cases(1).nav.t;
    targetTime=(navTime(1):cfg.sim.experiment.exportStride*cfg.dt:navTime(end)).';
    rows=unique([interp1(navTime,(1:numel(navTime)).',targetTime,'nearest');numel(navTime)]);
    current.t=navTime(rows);
    for c=1:numel(raw.system(s).cases)
        err=raw.system(s).cases(c).error;
        current.attitudeError(:,:,c)=err.attErr(rows,:);
        current.velocityError(:,:,c)=err.velErr(rows,:);
        current.positionError(:,:,c)=err.posErr(rows,:);
    end
    result.system(s)=current;
end
result.t=result.system(1).t;
end
