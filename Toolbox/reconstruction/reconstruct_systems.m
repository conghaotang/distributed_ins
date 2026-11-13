function rec = reconstruct_systems(measurement,array,cfg)
%RECONSTRUCT_SYSTEMS Reconstruct inertial quantities for all configured systems.
%
% Inputs
%   measurement - Global t/gyro/acc observation structure.
%   array - All-sensor calibration arrays with total accelerometer lever arms.
%   cfg - System layout and sim.reconstruction.referencePoint.
%
% Outputs
%   rec - t, referencePoint, and system entries with id, lever_b, wib_b, alpha_b, fb, and valid.
%
% Related functions
%   Calls array_reconstruct, select_system_array, split_system_measurements.
%   Called by navigation_cases.
%   Called by experiment main scripts.
measurementSystem=split_system_measurements(measurement,cfg);
for s=1:numel(cfg.system)
    systemArray=select_system_array(array,cfg.system(s), ...
        cfg.sim.reconstruction.referencePoint);
    current=array_reconstruct(measurementSystem(s),systemArray);
    current.id=cfg.system(s).id;
    current.lever_b=cfg.system(s).lever_b;
    systemResult(s)=current; %#ok<AGROW>
end
rec=struct('t',measurement.t,'referencePoint', ...
    cfg.sim.reconstruction.referencePoint,'system',systemResult);
end
