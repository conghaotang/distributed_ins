%FIGURE17_MAIN Generate ideal angular rates and origin specific forces for two IMUs.
% The two systems share angular rates, while their origin specific forces depend on the origin offsets.
% This experiment uses ideal reference motion.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
cfg=experiment_config(@figure17_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);

%% Generate reference motion for all systems
truth=avp_to_imu(avp,cfg,false);
clear avp

%% Retain times and reference values needed for plotting and export
sampleCount=numel(truth.t);
rows=(1:cfg.sim.experiment.exportStride:sampleCount).';
if rows(end)~=sampleCount, rows(end+1)=sampleCount; end
result=struct('t',truth.t(rows)-truth.t(1));
for s=1:numel(cfg.system)
    result.system(s).id=cfg.system(s).id;
    result.system(s).gyroTruth=truth.reference.system(s).wib_b(rows,:);
    result.system(s).forceTruth=truth.reference.system(s).fb(rows,:);
end
clear truth rows

%% Export all systems' three-axis reference values to two sheets in one workbook
excelFile=fullfile(figureDir,'figure17_ideal_motion.xlsx');
sheetNames={'AngularRate','SpecificForce'};
fields={'gyroTruth','forceTruth'};
components={{'OmegaX_deg_s','OmegaY_deg_s','OmegaZ_deg_s'}, ...
    {'ForceX_m_s2','ForceY_m_s2','ForceZ_m_s2'}};
factors=[180/pi,1];
systemCount=numel(result.system);
for q=1:2
    values=zeros(numel(result.t),1+3*systemCount);
    values(:,1)=result.t;
    names=cell(1,1+3*systemCount);
    names{1}='Time_s';
    for s=1:systemCount
        columns=1+3*(s-1)+(1:3);
        values(:,columns)=result.system(s).(fields{q})*factors(q);
        for j=1:3
            names{columns(j)}=sprintf('System%d%s',result.system(s).id,components{q}{j});
        end
    end
    comparisonTable=array2table(values,'VariableNames',names);
    if q==1, writeMode='replacefile'; else, writeMode='overwritesheet'; end
    writetable(comparisonTable,excelFile,'Sheet',sheetNames{q},'WriteMode',writeMode);
end
clear values names comparisonTable
plot_figure17(result);
save(fullfile(figureDir,'figure17_ideal_motion.mat'),'result','-v7');
