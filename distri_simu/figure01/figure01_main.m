%FIGURE01_MAIN Plot raw and unwrapped attitude sequences.
%   Run this script directly and choose the input file through sourceFile.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','marine_avp.mat');
cfg=experiment_config(@figure01_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
duration_h=cfg.sim.experiment.duration_h;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
avp = avp(avp(:,7) <= avp(1,7) + duration_h*3600, :);

attRaw = avp(:, 1:3);
% unwrapEuler expects [phi theta psi]. Reorder before and after the call.
attUnwrapped = unwrapEuler(attRaw(:,[2 1 3]));
attUnwrapped = attUnwrapped(:,[2 1 3]);
attRawDeg = rad2deg(attRaw);
attUnwrappedDeg = rad2deg(attUnwrapped);

excelDir = figureDir;
excelFile = fullfile(excelDir, 'figure01_attitude.xlsx');
exportIdx = (1:cfg.sim.experiment.exportStride:size(avp,1)).';
comparisonTable = table(avp(exportIdx,7)/3600, ...
    attRawDeg(exportIdx,1), attUnwrappedDeg(exportIdx,1), ...
    attRawDeg(exportIdx,2), attUnwrappedDeg(exportIdx,2), ...
    attRawDeg(exportIdx,3), attUnwrappedDeg(exportIdx,3), ...
    'VariableNames', {'Time_h','ThetaRaw_deg','ThetaUnwrapped_deg', ...
    'PhiRaw_deg','PhiUnwrapped_deg','PsiRaw_deg','PsiUnwrapped_deg'});
writetable(comparisonTable, excelFile, 'Sheet', 'Comparison', 'WriteMode', 'replacefile');

plot_figure01(avp, attRawDeg, attUnwrappedDeg);

report = struct('figure', 1, 'rows', size(avp,1), ...
    'excelFile', excelFile, 'sourceFile', sourceFile, ...
    'sourceColumns', '[theta phi psi B L H t]', 'units', 'attitude: deg; time: h');
