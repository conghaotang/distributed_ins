function cfg=config(configOverride)
%CONFIG Build sensor and algorithm settings and convert them to SI.
%
% Inputs
%   configOverride - Optional raw-configuration override handle, cfg = configOverride(cfg).
%
% Outputs
%   cfg - SI configuration containing earth, fs, dt, ins, layout, system, err, and unit.
%
% Related functions
%   Calls config_2.
%   Called by experiment_config.
cfg=struct;

%% Earth constants and numerical parameters
cfg.earth.a=6378137.0;                 % Semi-major axis, m.
cfg.earth.b=6356752.314245;            % Semi-minor axis, m.
cfg.earth.e2=1-(cfg.earth.b/cfg.earth.a)^2; % Squared first eccentricity, dimensionless.
cfg.earth.wie=7.292115e-5;             % Earth rotation rate, rad/s.
cfg.earth.g0=9.80665;                  % Gravity reference value, m/s^2.
cfg.earth.ge=9.7803253359;             % Equatorial normal gravity, m/s^2.
cfg.earth.k=0.00193185265241;          % Somigliana coefficient, dimensionless.

cfg.tol.dcm=1e-10;                     % Direction cosine matrix tolerance, dimensionless.

%% Simulation parameters

%% Sampling parameters
cfg.fs=100;                              % IMU sampling frequency, Hz.
cfg.dt=1/cfg.fs;                        % IMU sampling interval, s.
cfg.ins.subsampleCount=4;               % Subsamples per navigation update, from 1 to 6.

%% System layout, with one system per row and identifiers matching row numbers
% [systemId gyroCount accCount originLeverX originLeverY originLeverZ]
% Origin lever arms are relative to the main origin, expressed in the common b frame in mm.
% Order per-sensor parameters by system, with separate gyro and accelerometer indices.
% For [1 3 3 0 0 0; 2 3 3 500 0 0], also provide the six corresponding sensor parameters.
cfg.layout=[1 4 4 0 0 0];

%% Nominal gyro geometry and sensor error parameters
cfg.err.gyro.alphaDeg=19.4712;            % Angle between gyro A and x_b, deg.
cfg.err.gyro.nominalAxes=[ ...           % Rows are nominal A/B/C/D sensing axes in the b frame, dimensionless.
     cosd(cfg.err.gyro.alphaDeg), 0, sind(cfg.err.gyro.alphaDeg);
    -cosd(cfg.err.gyro.alphaDeg)/2, sqrt(3)*cosd(cfg.err.gyro.alphaDeg)/2, sind(cfg.err.gyro.alphaDeg);
    -cosd(cfg.err.gyro.alphaDeg)/2,-sqrt(3)*cosd(cfg.err.gyro.alphaDeg)/2, sind(cfg.err.gyro.alphaDeg);
     0, 0, 1];                           % Fourth sensing axis aligned with positive body z.
% Integer angular separations between actual and nominal gyro axes, in arcsec, up to 20.
cfg.err.gyro.directionErrorArcsec=[15;20;6;20];
% Fixed tilt bearings in the local tangent plane, deg.
cfg.err.gyro.directionErrorBearingDeg=[15.945396;-49.635463;51.340192;90];
cfg.err.gyro.bias=[0.07;-0.03;0.05;-0.08]; % Constant bias, deg/h.
cfg.err.gyro.scale=10*ones(4,1);          % Relative scale error, ppm, with gain 1+scale.
cfg.err.gyro.misalign=zeros(3);           % Actual directions are constructed from directionErrorArcsec.
cfg.err.gyro.noise=0.6*ones(4,1);         % Sample angular-rate white-noise standard deviation at the configured rate, deg/h.
cfg.err.gyro.randomWalk=zeros(4,1);       % Zero bias random walk.

%% Four-accelerometer geometry and error parameters
cfg.err.acc.nominalAxes=-cfg.err.gyro.nominalAxes; % Nominal accelerometer axes oppose the corresponding gyro axes.
% Installation errors, scales, and white noise are simulation selections.
cfg.err.acc.directionErrorArcsec=[12;18;9;16]; % Actual-to-nominal axis separation, arcsec.
cfg.err.acc.directionErrorBearingDeg=[30;135;225;315]; % Fixed tilt bearing, deg.
cfg.err.acc.bias=[700;300;-2000;100];      % Constant accelerometer biases, ug.
cfg.err.acc.scale=10*ones(4,1);           % Relative scale error, ppm.
cfg.err.acc.misalign=zeros(3);            % Actual axes already include installation errors.
cfg.err.acc.noise=10*ones(4,1);           % Sample white-noise standard deviation, ug, selected for simulation.
cfg.err.acc.randomWalk=zeros(4,1);        % White noise with zero bias random walk.
% Sensing-point offsets from the system origin in the b frame, mm, with A/B/C/D columns.
% config_2 adds each system origin offset to form total observation/reconstruction lever arms.
% Use 44-46 mm along the dominant nominal-axis direction and 2-4 mm transverse offsets.
% A is mainly x, B/C mainly y, and D mainly z, with selected lengths of 40-50 mm.
cfg.err.acc.location=[ ...
    -45,   4,   3,   2;
      3, -46,  44,  -3;
     -2,  -3,  -4, -45];

if nargin>0
    cfg=configOverride(cfg);
end
cfg=config_2(cfg);
end
