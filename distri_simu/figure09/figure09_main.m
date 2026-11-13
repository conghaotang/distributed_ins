%FIGURE09_MAIN Evaluate navigation errors for three calibration-residual cases.
figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','marine_avp.mat');
cfg=experiment_config(@figure09_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
truth=avp_to_imu(avp,cfg,false);
imu=struct('t',truth.t,'w',truth.wib_b,'wa',truth.alpha_b,'f',truth.fb);
rngBefore=rng;
rng(cfg.sim.experiment.noiseSeed);
imu=acc_meas(imu,cfg);
imu=gyro_meas(imu,cfg);
rng(rngBefore);
measurement=struct('t',truth.t,'gyro',imu.w,'acc',imu.f);
navigationResult=experiment_navigation_cases(measurement,truth.reference,cfg);
quantities={'attitude','velocity','position'};
sheetNames={'AttitudeError','VelocityError','PositionError'};
for s=1:numel(navigationResult.system)
    current=navigationResult.system(s);
    excelFile=fullfile(figureDir,sprintf('figure09_navigation_errors_system%d.xlsx',current.id));
    for q=1:3
        comparisonTable=export_cases(current,quantities{q});
        if q==1, writeMode='replacefile'; else, writeMode='overwritesheet'; end
        writetable(comparisonTable,excelFile,'Sheet',sheetNames{q},'WriteMode',writeMode);
        fig=plot_cases(current,quantities{q},9);
        set(fig,'Name',sprintf('Figure %02d System %d %s',9,current.id,quantities{q}));
    end
end
configuration=cfg;
save(fullfile(figureDir,'figure09_navigation_result.mat'),'navigationResult','configuration','-v7');
report=struct('figure',9,'sampleCount',numel(truth.t),'excelFile',excelFile);
