%FIGURE14_MAIN Compare origin specific force, centripetal acceleration, and tangential acceleration.
% All terms use b-frame components and the configured lever arms.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
cfg=experiment_config(@figure14_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
exportStride=cfg.sim.experiment.exportStride;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
% The toolbox supplies origin motion. This experiment separates the lever-arm acceleration terms.
truth = avp_to_imu(avp,cfg,false);
tq = truth.t;
queryRows = numel(tq);
leverVectors = cfg.sim.figure05.leverVectors_b;
originForce = truth.fb;
wib_b = truth.wib_b;
alpha_b = truth.alpha_b;
clear truth
centripetal = zeros(queryRows,3,2);
tangential = zeros(queryRows,3,2);
for leverIndex=1:2
    r = repmat(leverVectors(:,leverIndex).',queryRows,1);
    centripetal(:,:,leverIndex) = cross(wib_b,cross(wib_b,r,2),2);
    tangential(:,:,leverIndex) = cross(alpha_b,r,2);
end
clear r wib_b alpha_b
exportIdx = (1:exportStride:queryRows).';
termsTable = array2table([tq(exportIdx),originForce(exportIdx,1), ...
    centripetal(exportIdx,1,1),centripetal(exportIdx,1,2), ...
    tangential(exportIdx,1,1),tangential(exportIdx,1,2)], ...
    'VariableNames',{'Time_s','SpecificForceX_m_s2', ...
    'CentripetalSmallX_m_s2','CentripetalLargeX_m_s2', ...
    'TangentialSmallX_m_s2','TangentialLargeX_m_s2'});
% Small/Large correspond to the configured 50/100 mm lever-arm lengths.
excelFile = fullfile(figureDir,'figure14_specific_force_terms.xlsx');
writetable(termsTable,excelFile,'Sheet','ForceTerms','WriteMode','replacefile');

fig = plot_figure05(tq,originForce,centripetal,tangential,cfg.sim.figure05.leverLengthsMm,'s');
set(fig,'Name','Figure 14 specific-force terms');
report = struct('figure',14,'sourceFile',sourceFile,'samplingHz',cfg.fs, ...
    'queryRows',queryRows,'exportRows',numel(exportIdx),'exportStride',exportStride, ...
    'excelFile',excelFile,'leverVectors_b',leverVectors,'figureHandle',fig, ...
    'units','time: s; all force/acceleration components: m/s^2', ...
    'leverSource','engineering selection: 50/100 mm, same b-frame direction');
