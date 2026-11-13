function cfg=config_2(cfg)
%CONFIG_2 Convert raw sensor parameters and construct sensing axes and system indices.
%
% Inputs
%   cfg - Raw configuration. Lever arms use mm, scale errors ppm, direction errors arcsec, gyro
%       bias/noise deg/h, and accelerometer bias/noise ug.
%
% Outputs
%   cfg - SI configuration with actual axes, noise densities, Q, sensor indices, and total lever
%       arms. layout retains its input units.
%
% Related functions
%   Called by config.
layout=cfg.layout;
systemCount=size(layout,1);
cfg.system=repmat(struct('id',0,'gyroIndex',[],'accIndex',[], ...
    'lever_b',zeros(3,1)),1,systemCount);
gyroEnd=0; accEnd=0;
for s=1:systemCount
    cfg.system(s).id=layout(s,1);
    cfg.system(s).gyroIndex=gyroEnd+(1:layout(s,2));
    cfg.system(s).accIndex=accEnd+(1:layout(s,3));
    cfg.system(s).lever_b=layout(s,4:6).'*1e-3;
    gyroEnd=gyroEnd+layout(s,2);
    accEnd=accEnd+layout(s,3);
end

%% Convert units
cfg.unit.deg=pi/180;                     % deg -> rad
cfg.unit.minute=60;                      % min -> s
cfg.unit.hour=3600;                      % h -> s
cfg.unit.sqrtHour=sqrt(cfg.unit.hour);   % sqrt(h) -> sqrt(s)
cfg.unit.arcmin=cfg.unit.deg/cfg.unit.minute;
cfg.unit.arcsec=cfg.unit.deg/cfg.unit.hour;
cfg.unit.ppm=1e-6;                       % ppm to dimensionless.
cfg.unit.ug=1e-6*cfg.earth.g0;          % ug -> m/s^2
cfg.unit.nauticalMile=1852;              % nmi -> m
cfg.unit.gyroBias=cfg.unit.deg/cfg.unit.hour;
cfg.unit.gyroArw=cfg.unit.deg/cfg.unit.sqrtHour;
cfg.unit.gyroRrw=cfg.unit.deg ...
    /cfg.unit.hour/cfg.unit.sqrtHour;
cfg.unit.accRw=cfg.unit.ug/cfg.unit.sqrtHour;

% Gyroscopes
%   deg/h              -> rad/s
%   Convert sample standard deviation from deg/h to density for division by sqrt(dt) in gyro_meas.
%   (deg/h)/sqrt(h)    -> (rad/s)/sqrt(s)
cfg.err.gyro.bias=cfg.err.gyro.bias*cfg.unit.gyroBias;
cfg.err.gyro.scale=cfg.err.gyro.scale*cfg.unit.ppm;
cfg.err.gyro.misalign=cfg.err.gyro.misalign*cfg.unit.arcsec;
cfg.err.gyro.noise=cfg.err.gyro.noise*cfg.unit.gyroBias*sqrt(cfg.dt);
cfg.err.gyro.randomWalk= ...
    cfg.err.gyro.randomWalk*cfg.unit.gyroRrw;

% Each axis uses one separation angle and a fixed tilt bearing in its local tangent plane.
cfg.err.gyro.directionError=cfg.err.gyro.directionErrorArcsec*cfg.unit.arcsec;
cfg.err.gyro.directionErrorBearing=cfg.err.gyro.directionErrorBearingDeg*cfg.unit.deg;
cfg.err.gyro.axes=zeros(size(cfg.err.gyro.nominalAxes));
for gyroIndex=1:size(cfg.err.gyro.nominalAxes,1)
    nominalAxis=cfg.err.gyro.nominalAxes(gyroIndex,:).';
    [~,basisIndex]=min(abs(nominalAxis));
    basisAxis=zeros(3,1);
    basisAxis(basisIndex)=1;
    tangent1=cross(nominalAxis,basisAxis);
    tangent1=tangent1/norm(tangent1);
    tangent2=cross(nominalAxis,tangent1);
    tiltDirection=cos(cfg.err.gyro.directionErrorBearing(gyroIndex))*tangent1 ...
        +sin(cfg.err.gyro.directionErrorBearing(gyroIndex))*tangent2;
    actualAxis=cos(cfg.err.gyro.directionError(gyroIndex))*nominalAxis ...
        +sin(cfg.err.gyro.directionError(gyroIndex))*tiltDirection;
    cfg.err.gyro.axes(gyroIndex,:)=(actualAxis/norm(actualAxis)).';
end

% Accelerometers
%   ug                 -> m/s^2
%   Convert sample standard deviation from ug to density for division by sqrt(dt) in acc_meas.
%   ug/sqrt(h)         -> (m/s^2)/sqrt(s)
cfg.err.acc.bias=cfg.err.acc.bias*cfg.unit.ug;
cfg.err.acc.scale=cfg.err.acc.scale*cfg.unit.ppm;
cfg.err.acc.misalign=cfg.err.acc.misalign*cfg.unit.arcsec;
cfg.err.acc.noise=cfg.err.acc.noise*sqrt(cfg.dt)*cfg.unit.ug;
cfg.err.acc.randomWalk=cfg.err.acc.randomWalk*cfg.unit.accRw;
cfg.err.acc.location=cfg.err.acc.location*1e-3;
% Store internal lever arms and expose total common-origin lever arms through location.
% Add origin offsets once during unit conversion.
cfg.err.acc.internalLocation=cfg.err.acc.location;
for s=1:systemCount
    j=cfg.system(s).accIndex;
    cfg.err.acc.location(:,j)=cfg.err.acc.internalLocation(:,j)+cfg.system(s).lever_b;
end

cfg.err.acc.directionError=cfg.err.acc.directionErrorArcsec*cfg.unit.arcsec;
cfg.err.acc.directionErrorBearing=cfg.err.acc.directionErrorBearingDeg*cfg.unit.deg;
cfg.err.acc.axes=zeros(size(cfg.err.acc.nominalAxes));
for accIndex=1:size(cfg.err.acc.nominalAxes,1)
    nominalAxis=cfg.err.acc.nominalAxes(accIndex,:).';
    [~,basisIndex]=min(abs(nominalAxis));
    basisAxis=zeros(3,1);
    basisAxis(basisIndex)=1;
    tangent1=cross(nominalAxis,basisAxis);
    tangent1=tangent1/norm(tangent1);
    tangent2=cross(nominalAxis,tangent1);
    tiltDirection=cos(cfg.err.acc.directionErrorBearing(accIndex))*tangent1 ...
        +sin(cfg.err.acc.directionErrorBearing(accIndex))*tangent2;
    actualAxis=cos(cfg.err.acc.directionError(accIndex))*nominalAxis ...
        +sin(cfg.err.acc.directionError(accIndex))*tiltDirection;
    cfg.err.acc.axes(accIndex,:)=(actualAxis/norm(actualAxis)).';
end

cfg.err.gyro.Q=diag((cfg.err.gyro.noise/sqrt(cfg.dt)).^2);
cfg.err.acc.Q=diag((cfg.err.acc.noise/sqrt(cfg.dt)).^2);

end
