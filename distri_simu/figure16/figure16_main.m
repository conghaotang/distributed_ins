%FIGURE16_MAIN Compare system positions and local-navigation attitudes over the first 50 s.
% Use toolbox reference motion for this trajectory-preparation experiment.
% Translate the same source trajectory to each system origin using cfg.layout lever arms.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
cfg=experiment_config(@figure16_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
timeRange_s=cfg.sim.experiment.timeRange_s;
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);

%% Generate reference motion for all systems
% Use cfg.system expanded from cfg.layout by config_2.
t0=avp(1,7);
queryTime=timeRange_s(1)+(0:floor(diff(timeRange_s)*cfg.fs)).'*cfg.dt;
tq=t0+queryTime;
sourceAvp=avp(avp(:,7)>=t0+timeRange_s(1) & avp(:,7)<=t0+timeRange_s(2),:);
% Select every second source node for display/export and use all avp nodes for spline construction.
sourceAvp=sourceAvp(1:cfg.sim.experiment.sourceExportStride:end,:);
sourceTime=sourceAvp(:,7)-t0;
% Combine source-node times and 100 Hz query times in one reference-generation call.
% Splines interpolate the source AVP nodes, and refere_sys performs origin translations.
[evaluationTime,~,timeIndex]=unique([sourceAvp(:,7);tq]);
sourceRows=timeIndex(1:numel(sourceTime));
queryRows=timeIndex(numel(sourceTime)+1:end);
truth=avp_to_imu(avp,cfg,false,struct('t',evaluationTime));

%% Extract source nodes and interpolated series for all configured systems
systemCount=numel(cfg.system);
result=struct('sourceTime',sourceTime,'queryTime',queryTime);
for s=1:systemCount
    result.system(s).id=truth.reference.system(s).id;
    result.system(s).sourcePosition=truth.reference.system(s).pos(sourceRows,:);
    result.system(s).position=truth.reference.system(s).pos(queryRows,:);
    % Use each origin's C_b^n and the toolbox unwrapping function.
    % unwrapEuler uses [phi theta psi]. Restore AVP ordering [theta phi psi] afterward.
    attitude=unwrapEuler(truth.reference.system(s).att(:,[2 1 3]));
    attitude=attitude(:,[2 1 3]);
    result.system(s).sourceAttitude=attitude(sourceRows,:);
    result.system(s).attitude=attitude(queryRows,:);
end
clear truth avp sourceAvp evaluationTime timeIndex sourceRows queryRows tq t0 attitude

%% Export every second source node and all interpolation samples
% Write position and attitude sheets, including attitude differences from system 1 in arcsec.
% Source and interpolated series have separate time columns, with trailing empty cells for shorter series.
excelFile=fullfile(figureDir,'figure16_dual_system_positions.xlsx');
sheetNames={'Position','Attitude'};
groupWidth=1+3*systemCount;
for quantity=1:2
    if quantity==1
        sourceField='sourcePosition'; queryField='position';
        components={'Latitude_deg','Longitude_deg','Height_m'};
        factors=[180/pi,180/pi,1];
        columnCount=2*groupWidth;
    else
        sourceField='sourceAttitude'; queryField='attitude';
        components={'Pitch_deg','Roll_deg','Heading_deg'};
        factors=[180/pi,180/pi,180/pi];
        columnCount=2*groupWidth+6*(systemCount-1);
    end
    values=NaN(max(numel(sourceTime),numel(queryTime)),columnCount);
    values(1:numel(sourceTime),1)=sourceTime;
    values(1:numel(queryTime),groupWidth+1)=queryTime;
    names=cell(1,columnCount);
    names{1}='SourceTime_s';
    names{groupWidth+1}='InterpolatedTime_s';
    for s=1:systemCount
        sourceColumns=1+3*(s-1)+(1:3);
        queryColumns=groupWidth+sourceColumns;
        values(1:numel(sourceTime),sourceColumns)=result.system(s).(sourceField).*factors;
        values(1:numel(queryTime),queryColumns)=result.system(s).(queryField).*factors;
        for j=1:3
            names{sourceColumns(j)}=sprintf('System%dSource%s',result.system(s).id,components{j});
            names{queryColumns(j)}=sprintf('System%dInterpolated%s',result.system(s).id,components{j});
        end
    end
    if quantity==2
        angleNames={'Pitch','Roll','Heading'};
        for s=2:systemCount
            sourceColumns=2*groupWidth+3*(s-2)+(1:3);
            queryColumns=sourceColumns+3*(systemCount-1);
            delta=result.system(s).sourceAttitude-result.system(1).sourceAttitude;
            values(1:numel(sourceTime),sourceColumns)=atan2(sin(delta),cos(delta))*180/pi*3600;
            delta=result.system(s).attitude-result.system(1).attitude;
            values(1:numel(queryTime),queryColumns)=atan2(sin(delta),cos(delta))*180/pi*3600;
            for j=1:3
                names{sourceColumns(j)}=sprintf('System%dMinusSystem%dSource%s_arcsec', ...
                    result.system(s).id,result.system(1).id,angleNames{j});
                names{queryColumns(j)}=sprintf('System%dMinusSystem%dInterpolated%s_arcsec', ...
                    result.system(s).id,result.system(1).id,angleNames{j});
            end
        end
    end
    comparisonTable=array2table(values,'VariableNames',names);
    if quantity==1, writeMode='replacefile'; else, writeMode='overwritesheet'; end
    writetable(comparisonTable,excelFile,'Sheet',sheetNames{quantity},'WriteMode',writeMode);
end
clear values names comparisonTable delta
plot_figure16(result);
resultFile=fullfile(figureDir,'figure16_dual_system_positions.mat');
save(resultFile,'result','-v7');
