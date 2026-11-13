%FIGURE00_MAIN Plot the input longitude/latitude trajectory and export Excel data.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','marine_avp.mat');
cfg=experiment_config(@figure00_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);

latitude_deg = rad2deg(avp(:,4));
longitude_deg = rad2deg(avp(:,5));
exportIdx = (1:cfg.sim.experiment.exportStride:size(avp,1)).';
sourceTable = table(avp(exportIdx,7)/3600, longitude_deg(exportIdx), ...
    latitude_deg(exportIdx), avp(exportIdx,6), ...
    'VariableNames', {'Time_h','Longitude_deg','Latitude_deg','Height_m'});
excelFile = fullfile(figureDir, 'figure00_trajectory.xlsx');
writetable(sourceTable, excelFile, 'Sheet', 'Trajectory', 'WriteMode', 'replacefile');

fig = plot_figure00(longitude_deg, latitude_deg);
report = struct('figure', 0, 'rows', size(avp,1), ...
    'exportRows', numel(exportIdx), 'excelFile', excelFile, ...
    'sourceFile', sourceFile, 'figureHandle', fig);
