function system = split_system_measurements(measurement,cfg)
%SPLIT_SYSTEM_MEASUREMENTS Select each system's observation columns.
%
% Inputs
%   measurement - Global t (N-by-1, s), gyro (N-by-Mg, rad/s), and acc (N-by-Ma, m/s^2).
%   cfg - Configuration with system-specific gyroIndex and accIndex.
%
% Outputs
%   system - System structure array with layout metadata and selected t/gyro/acc arrays.
%
% Related functions
%   Called by avp_to_imu, reconstruct_systems.
system=cfg.system;
for s=1:numel(system)
    system(s).t=measurement.t;
    system(s).gyro=measurement.gyro(:,system(s).gyroIndex);
    system(s).acc=measurement.acc(:,system(s).accIndex);
end
end
