%FIGURE06_MAIN Generate four accelerometer measurements with centripetal and tangential lever-arm terms.
% Parameters come from Toolbox/configuration/config.m, with nominal Ha=-Hg and independent installation errors.


figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','marine_avp.mat');
cfg=experiment_config(@figure06_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
exportStride=cfg.sim.experiment.exportStride;
noiseSeed=cfg.sim.experiment.noiseSeed;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
% Generate origin motion with the toolbox, then all accelerometer measurements with acc_meas.
truth = avp_to_imu(avp,cfg,false);
tq = truth.t;
queryRows = numel(tq);
imu = struct('t',tq,'w',truth.wib_b,'wa',truth.alpha_b,'f',truth.fb);
clear truth
previousRng = rng;
rng(noiseSeed);
[imu,accBiasRandomWalk] = acc_meas(imu,cfg);
rng(previousRng);
accObservation = imu.f;
clear imu
exportIdx = (1:exportStride:queryRows).';
observationTable = table(tq(exportIdx)/3600, ...
    accObservation(exportIdx,1),accObservation(exportIdx,2), ...
    accObservation(exportIdx,3),accObservation(exportIdx,4), ...
    'VariableNames',{'Time_h','AccA_m_s2','AccB_m_s2','AccC_m_s2','AccD_m_s2'});
excelFile = fullfile(figureDir,'figure06_acc_observations.xlsx');
writetable(observationTable,excelFile,'Sheet','Observations','WriteMode','replacefile');

fig = plot_figure06(tq,accObservation);
report = struct('figure',6,'sourceFile',sourceFile, ...
    'sourceRows',size(avp,1),'queryRows',queryRows,'samplingHz',cfg.fs, ...
    'duration_h',(tq(end)-tq(1))/3600,'exportStride',exportStride, ...
    'exportRows',numel(exportIdx),'excelFile',excelFile,'noiseSeed',noiseSeed, ...
    'sensorLocations_b',cfg.err.acc.location,'leverArmEnabled',true,'figureHandle',fig, ...
    'units','time: h; accelerometer observations: m/s^2', ...
    'measurementSource','Toolbox/measurement_module/acc_meas');
