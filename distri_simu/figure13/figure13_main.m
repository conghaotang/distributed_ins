%FIGURE13_MAIN Compare source heading/position and 100 Hz splines over the first 50 s.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
distributedDir=fileparts(fileparts(figureDir));
cfg=experiment_config(@figure13_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
timeRange_s=cfg.sim.experiment.timeRange_s;
reconstructionHz=cfg.sim.experiment.reconstructionHz;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
% Evaluate heading, latitude, and longitude from the shared global trajectory splines.
pp = data_interp(avp);
timeStart_s = avp(1,7) + timeRange_s(1);
timeEnd_s = min(avp(end,7), avp(1,7) + timeRange_s(2));
tq = timeStart_s + (0:floor((timeEnd_s-timeStart_s)*reconstructionHz)).'/reconstructionHz;
truth = struct('t', tq, 'yaw', EvalSplineAll(pp.psi,tq), ...
    'latitude', EvalSplineAll(pp.B,tq), 'longitude', EvalSplineAll(pp.L,tq));
avp = avp(avp(:,7) >= timeStart_s & avp(:,7) <= timeEnd_s, :);

excelFile = fullfile(figureDir, 'figure13_navigation_interpolation.xlsx');
% Export every second source node and all 100 Hz interpolation samples, each with its own time column.
sourceIdx = (1:cfg.sim.experiment.sourceExportStride:size(avp,1)).';
sourceData = [avp(sourceIdx,7), rad2deg(avp(sourceIdx,3:5))];
modelData = [truth.t, rad2deg([truth.yaw, truth.latitude, truth.longitude])];
exportData = NaN(max(size(sourceData,1),size(modelData,1)), 8);
exportData(1:size(sourceData,1),1:4) = sourceData;
exportData(1:size(modelData,1),5:8) = modelData;
comparisonTable = array2table(exportData, 'VariableNames', ...
    {'SourceTime_s','SourceYaw_deg','SourceLatitude_deg','SourceLongitude_deg', ...
    'ModelTime_s','ModelYaw_deg','ModelLatitude_deg','ModelLongitude_deg'});
writetable(comparisonTable,excelFile,'Sheet','Comparison','WriteMode','replacefile');

plot_figure13(avp, truth);

report = struct('figure', 13, 'sourceFile', sourceFile, ...
    'distributedDir', distributedDir, 'excelFile', excelFile, ...
    'sourceRows', size(avp,1), 'queryRows', numel(tq), ...
    'reconstructionHz', reconstructionHz, 'duration_s', tq(end)-tq(1), ...
    'units', 'time: s; yaw/latitude/longitude: deg', ...
    'interpolationSource', 'Toolbox data_interp/EvalSplineAll; not-a-knot');
