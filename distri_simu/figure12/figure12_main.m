%FIGURE12_MAIN Input-trajectory attitude sequence and unwrapped sequence.
figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
cfg=experiment_config(@figure12_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
attRaw = avp(:,1:3);
% unwrapEuler expects [phi theta psi]. Reorder before and after the call.
attUnwrapped = unwrapEuler(attRaw(:,[2 1 3]));
attUnwrapped = attUnwrapped(:,[2 1 3]);
excelFile = fullfile(figureDir, 'figure12_attitude.xlsx');
comparisonTable = table(avp(:,7),rad2deg(attRaw(:,1)),rad2deg(attUnwrapped(:,1)), ...
    rad2deg(attRaw(:,2)),rad2deg(attUnwrapped(:,2)),rad2deg(attRaw(:,3)),rad2deg(attUnwrapped(:,3)), ...
    'VariableNames',{'Time_s','ThetaRaw_deg','ThetaUnwrapped_deg', ...
    'PhiRaw_deg','PhiUnwrapped_deg','PsiRaw_deg','PsiUnwrapped_deg'});
writetable(comparisonTable,excelFile,'Sheet','Comparison','WriteMode','replacefile');
plot_figure12(avp, attRaw, attUnwrapped);

report = struct('figure', 12, 'rows', size(avp,1), ...
    'excelFile', excelFile, 'sourceFile', sourceFile, ...
    'sourceColumns', '[theta phi psi B L H t]', 'units', 'theta/phi/psi/B/L: rad; H: m; t: s');
