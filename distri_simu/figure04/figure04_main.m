%FIGURE04_MAIN Generate and plot four single-axis gyro measurements.


figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','marine_avp.mat');
cfg=experiment_config(@figure04_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
exportStride=cfg.sim.experiment.exportStride;
noiseSeed=cfg.sim.experiment.noiseSeed;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
% Generate ideal angular motion with the toolbox and gyro observations with gyro_meas.
truth = avp_to_imu(avp,cfg,false);
tq = truth.t;
queryRows = numel(tq);
wib_b = truth.wib_b;
clear truth
% gyro_meas uses cfg.err.gyro.axes, which already includes direction errors.
% y_j=(1+scale_j)*mu_j'*wib_b+bias_j+white_noise_j。
imu = struct('t',tq,'w',wib_b);
previousRng = rng;
rng(noiseSeed);
[imu,gyroBiasRandomWalk] = gyro_meas(imu,cfg);
rng(previousRng);
gyroObservation = imu.w;

exportIdx = (1:exportStride:queryRows).';
observationTable = table(tq(exportIdx)/3600, ...
    rad2deg(gyroObservation(exportIdx,1)), rad2deg(gyroObservation(exportIdx,2)), ...
    rad2deg(gyroObservation(exportIdx,3)), rad2deg(gyroObservation(exportIdx,4)), ...
    'VariableNames', {'Time_h','GyroA_deg_s','GyroB_deg_s','GyroC_deg_s','GyroD_deg_s'});
excelFile = fullfile(figureDir,'figure04_gyro_observations.xlsx');
writetable(observationTable,excelFile,'Sheet','Observations','WriteMode','replacefile');

fig = plot_figure04(tq,gyroObservation);
report = struct('figure',4,'sourceFile',sourceFile, ...
    'sourceRows',size(avp,1),'queryRows',queryRows,'samplingHz',cfg.fs, ...
    'duration_h',(tq(end)-tq(1))/3600,'exportStride',exportStride, ...
    'exportRows',numel(exportIdx),'excelFile',excelFile,'noiseSeed',noiseSeed, ...
    'units','time: h; gyro observations: deg/s','figureHandle',fig, ...
    'measurementSource','Toolbox/measurement_module/gyro_meas');
