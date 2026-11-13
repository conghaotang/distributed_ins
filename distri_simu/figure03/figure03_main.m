%FIGURE03_MAIN Export toolbox-derived body angular rate and acceleration.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','marine_avp.mat');
cfg=experiment_config(@figure03_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
reconstructionHz=cfg.sim.experiment.reconstructionHz;
exportStride=cfg.sim.experiment.exportStride;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
% Use the common data-generation entry point and its analytic angular derivatives.
queryRows = floor((avp(end,7)-avp(1,7))*reconstructionHz)+1;
tq = avp(1,7) + (0:queryRows-1).'/reconstructionHz;
data = avp_to_imu(avp,cfg,false,struct('t',tq));
truth = struct('t',data.t,'wib_b',data.wib_b,'alpha_b',data.alpha_b);
clear data
excelFile = fullfile(figureDir, 'figure03_body_angular_motion.xlsx');
exportIdx = (1:exportStride:queryRows).';
motionTable = table(truth.t(exportIdx)/3600, rad2deg(truth.wib_b(exportIdx,1)), rad2deg(truth.wib_b(exportIdx,2)), ...
    rad2deg(truth.wib_b(exportIdx,3)), rad2deg(truth.alpha_b(exportIdx,1)), rad2deg(truth.alpha_b(exportIdx,2)), rad2deg(truth.alpha_b(exportIdx,3)), ...
    'VariableNames', {'Time_h','OmegaX_deg_s','OmegaY_deg_s','OmegaZ_deg_s', ...
    'AlphaX_deg_s2','AlphaY_deg_s2','AlphaZ_deg_s2'});
writetable(motionTable, excelFile, 'Sheet', 'AngularMotion', 'WriteMode', 'replacefile');

plot_figure03(truth);

report = struct('figure', 3, 'sourceFile', sourceFile, ...
    'excelFile', excelFile, 'sourceRows', size(avp,1), ...
    'queryRows', queryRows, 'reconstructionHz', reconstructionHz, ...
    'exportStride', exportStride, 'exportRows', numel(exportIdx), ...
    'units', 'time h; angular rate deg/s; angular acceleration deg/s^2', ...
    'idgSource', 'Toolbox/data/avp_to_imu');
