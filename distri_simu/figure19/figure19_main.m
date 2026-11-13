%FIGURE19_MAIN Evaluate attitude, velocity, and position errors at two IMU origins.
% Use distinct sensor errors and 0%, 5%, and 30% residuals, with full-rate measurements.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
cfg=experiment_config(@figure19_config);
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

%% Run shared reconstruction and navigation cases
result=experiment_navigation_cases(measurement,reference,cfg);
clear measurement reference

%% Export attitude, velocity, and position errors to three sheets in one workbook
quantities={'attitude_arcsec','velocity','position'};
sheetNames={'AttitudeError','VelocityError','PositionError'};
excelFile=fullfile(figureDir,'figure19_navigation_errors.xlsx');
for q=1:numel(quantities)
    for s=1:numel(result.system)
        systemTable=export_cases(result.system(s),quantities{q});
        % Share one time column and prefix other columns with the system identifier.
        systemTable.Properties.VariableNames(2:end)=strcat( ...
            sprintf('System%d_',result.system(s).id),systemTable.Properties.VariableNames(2:end));
        if s==1
            comparisonTable=systemTable;
        else
            comparisonTable=[comparisonTable,systemTable(:,2:end)];
        end
    end
    if q==1, writeMode='replacefile'; else, writeMode='overwritesheet'; end
    writetable(comparisonTable,excelFile,'Sheet',sheetNames{q},'WriteMode',writeMode);
end
clear systemTable comparisonTable

%% Plot each system using the common navigation-error functions
for s=1:numel(result.system)
    for q=1:numel(quantities)
        fig=plot_cases(result.system(s),quantities{q},19);
        set(fig,'Name',sprintf('Figure 19 System %d %s',result.system(s).id,quantities{q}));
    end
end
save(fullfile(figureDir,'figure19_navigation_errors.mat'),'result','-v7');
