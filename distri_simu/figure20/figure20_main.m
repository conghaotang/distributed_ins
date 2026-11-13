%FIGURE20_MAIN Evaluate navigation errors for one distributed three-axis IMU.
% Use orthogonal nominal sensing axes, separated sensor centers, and configured sensor errors.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
cfg=experiment_config(@figure20_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);

%% Generate reference motion and measurements
truth=avp_to_imu(avp,cfg,false);
imu=struct('t',truth.t,'w',truth.wib_b,'wa',truth.alpha_b,'f',truth.fb);
rngBefore=rng;
rng(cfg.sim.experiment.noiseSeed);
imu=acc_meas(imu,cfg);
imu=gyro_meas(imu,cfg);
rng(rngBefore);
measurement=struct('t',truth.t,'gyro',imu.w,'acc',imu.f);
reference=truth.reference;
clear truth imu avp

%% Use the reconstruction, navigation, and error-evaluation chain shared with dual-system experiments
result=experiment_navigation_cases(measurement,reference,cfg);
clear measurement reference

%% Export and plot attitude, velocity, and position errors separately
quantities={'attitude','velocity','position'};
for q=1:numel(quantities)
    excelFile=fullfile(figureDir,sprintf('figure20_%s_error.xlsx',quantities{q}));
    export_cases(result.system(1),quantities{q},excelFile);
    fig=plot_cases(result.system(1),quantities{q},20);
    set(fig,'Name',sprintf('Figure 20 single distributed IMU %s',quantities{q}));
end
save(fullfile(figureDir,'figure20_navigation_errors.mat'),'result','-v7');
