%FIGURE07_MAIN Compare three corrected angular-rate estimates against ideal rates, in deg/h.
figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','marine_avp.mat');
cfg=experiment_config(@figure07_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
exportStride=cfg.sim.experiment.exportStride;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
%% Generate reference motion
truth=avp_to_imu(avp,cfg,false);

%% Generate sensor measurements
t=truth.t;
sampleCount=numel(t);
% Generate one measurement realization and share it across all calibration cases.
imu=struct('t',t,'w',truth.wib_b,'wa',truth.alpha_b,'f',truth.fb);
rngBefore=rng; rng(cfg.sim.experiment.noiseSeed);
imu=acc_meas(imu,cfg);
imu=gyro_meas(imu,cfg);
rng(rngBefore);
measurement=struct('t',t,'gyro',imu.w,'acc',imu.f);
clear imu

%% Configure reconstruction cases
cases=calibration_cases(cfg);
sampleIndex=(2:exportStride:sampleCount).';
if sampleIndex(end)~=sampleCount, sampleIndex(end+1)=sampleCount; end
caseCount=numel(cases); systemCount=numel(cfg.system);
outputCount=numel(sampleIndex);
template=struct('sourceFile',sourceFile,'sampleCount',sampleCount, ...
    'samplingHz',cfg.fs,'sampleIndex',sampleIndex,'t',t(sampleIndex), ...
    'caseNames',{cfg.sim.calibration.names}, ...
    'residualFractions',cfg.sim.calibration.residualFractions, ...
    'navigationComputed',false,'wTruth',truth.wib_b(sampleIndex,:), ...
    'fTruth',zeros(outputCount,3),'wEstimate',zeros(outputCount,3,caseCount), ...
    'fEstimate',zeros(outputCount,3,caseCount),'gyroRms',zeros(caseCount,3), ...
    'forceRms',zeros(caseCount,3),'validSampleCount',sampleCount-1, ...
    'referencePoint',cfg.sim.reconstruction.referencePoint,'id',0, ...
    'gyroIndex',[],'accIndex',[],'lever_b',zeros(3,1),'gyro',[],'acc',[]);
reconstructionResult=struct('sourceFile',sourceFile, ...
    'sampleCount',sampleCount,'samplingHz',cfg.fs,'sampleIndex',sampleIndex, ...
    't',t(sampleIndex),'systemCount',systemCount, ...
    'referencePoint',cfg.sim.reconstruction.referencePoint, ...
    'system',repmat(template,1,systemCount));
for s=1:systemCount
    current=template;
    current.id=cfg.system(s).id;
    current.gyroIndex=cfg.system(s).gyroIndex;
    current.accIndex=cfg.system(s).accIndex;
    current.lever_b=cfg.system(s).lever_b;
    current.gyro=measurement.gyro(sampleIndex,current.gyroIndex);
    current.acc=measurement.acc(sampleIndex,current.accIndex);
    switch cfg.sim.reconstruction.referencePoint
        case 'common_origin'
            trueF=truth.fb;
        case 'system_origin'
            trueF=truth.reference.system(s).fb;
    end
    current.fTruth=trueF(sampleIndex,:);
    reconstructionCfg=cfg;
    reconstructionCfg.system=cfg.system(s);
    for c=1:caseCount
        reconstructed=reconstruct_systems(measurement,cases(c).array,reconstructionCfg);
        rec=reconstructed.system(1);
        current.wEstimate(:,:,c)=rec.wib_b(sampleIndex,:);
        current.fEstimate(:,:,c)=rec.fb(sampleIndex,:);
        current.gyroRms(c,:)=sqrt(mean((rec.wib_b(2:end,:)-truth.wib_b(2:end,:)).^2,1));
        current.forceRms(c,:)=sqrt(mean((rec.fb(2:end,:)-trueF(2:end,:)).^2,1));
    end
    reconstructionResult.system(s)=current;
end
clear truth measurement reconstructed rec

configuration=cfg;
resultFile=fullfile(figureDir,'figure07_reconstruction_result.mat');
save(resultFile,'reconstructionResult','configuration','-v7');
% All three cases are corrected estimates. The first uses true error parameters and includes white noise.
% Subtract the trajectory-derived ideal rate from each estimate to calculate its error.
% Save reconstruction outputs for subsequent plotting and error statistics.
% Store all systems in MAT and export/plot each system separately.
reports=cell(1,reconstructionResult.systemCount);
fig=gobjects(1,reconstructionResult.systemCount);
for systemIndex=1:reconstructionResult.systemCount
    displayResult=reconstructionResult.system(systemIndex);
    displayResult.caseNames={'TrueParametersError','SmallResidualError','LargeResidualError'};
    excelFile=fullfile(figureDir,sprintf('figure07_angular_velocity_system%d.xlsx',displayResult.id));
    comparisonTable=export_cases(displayResult,'gyro_error',excelFile);
    fig(systemIndex)=plot_cases(displayResult,'gyro_error',7);
    set(fig(systemIndex),'Name',sprintf('Figure 07 System %d',displayResult.id));
    set(findall(fig(systemIndex),'Type','line','DisplayName','Exact calibration'), ...
        'DisplayName','True-parameter correction');
    set(findall(fig(systemIndex),'Type','legend'),'Location','northeast');
    reports{systemIndex}=struct('figure',7,'systemId',displayResult.id, ...
        'excelFile',excelFile,'resultFile',resultFile, ...
        'sampleCount',reconstructionResult.sampleCount,'rms',displayResult.gyroRms);
end
report=[reports{:}];
