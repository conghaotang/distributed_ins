%% Distributed inertial navigation example
% Use a synthetic 321 trajectory, with time in s, angles in rad, and lengths in m.
% Display figures and export Excel alongside this script.
scriptDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(scriptDir);
addpath(genpath(rootDir));
[cfg,avp]=demo_config();
rng(cfg.sim.experiment.noiseSeed,'twister');

%% Run interpolation, measurement generation, calibration/reconstruction, INS, and error evaluation
truth=avp_to_imu(avp,cfg,true);
result=navigation_cases(truth.measurement,truth.reference,cfg);
outputFile=fullfile(scriptDir,'demo_navigation.xlsx');
for s=1:numel(result.system)
    figure('Name',sprintf('System %d navigation errors',result.system(s).id));
    for c=1:numel(result.system(s).cases)
        current=result.system(s).cases(c);
        err=current.error;
        time=err.t/3600;
        subplot(3,1,1);
        plot(time,vecnorm(err.attErr,2,2)*180/pi*3600,'DisplayName',current.name);
        hold on; grid on; ylabel('Attitude norm (arcsec)');
        subplot(3,1,2);
        plot(time,vecnorm(err.velErr,2,2),'DisplayName',current.name);
        hold on; grid on; ylabel('Velocity norm (m/s)');
        subplot(3,1,3);
        plot(time,vecnorm(err.posErr,2,2),'DisplayName',current.name);
        hold on; grid on; ylabel('Position norm (m)'); xlabel('Time (h)');
        legend('Location','best');
        % Export the nearest navigation state every 1000 IMU intervals and include the final state.
        targetTime=(err.t(1):cfg.sim.experiment.exportStride*cfg.dt:err.t(end)).';
        selected=interp1(err.t,(1:numel(err.t)).',targetTime,'nearest');
        selected=unique([selected;numel(err.t)]);
        values=[time(selected),err.attErr(selected,:)*180/pi*3600, ...
            err.velErr(selected,:),err.posErr(selected,:)];
        tableOut=array2table(values,'VariableNames', ...
            {'Time_h','PhiE_arcsec','PhiN_arcsec','PhiU_arcsec', ...
             'VelE_mps','VelN_mps','VelU_mps','PosE_m','PosN_m','PosU_m'});
        sheet=sprintf('System%d_%s',result.system(s).id,current.name);
        writetable(tableOut,outputFile,'Sheet',sheet,'WriteMode','overwritesheet');
        fprintf('System %d %s: max position norm %.6g m\n', ...
            result.system(s).id,current.name,max(vecnorm(err.posErr,2,2)));
    end
end
fprintf('Excel: %s\n',outputFile);
fprintf('Unused tail samples: %d\n',result.omittedTailSamples);
