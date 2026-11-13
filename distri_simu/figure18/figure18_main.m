%FIGURE18_MAIN Plot origin force and two lever-arm terms for both systems, giving six curves.
% refere_sys generates origin force, and acc_meas supplies internal lever-arm terms.
% Use the x accelerometer's internal lever arm and plot ideal b-frame x components.

figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
% Specify the input file in this script using any file with the documented AVP format.
sourceFile=fullfile(rootDir,'data','land_ginav_avp.mat');
cfg=experiment_config(@figure18_config);
if exist('experimentDuration_s','var')
    cfg.sim.experiment.duration_s=experimentDuration_s;
end
loaded=load(sourceFile,'avp');
avp=loaded.avp;
avp=avp(avp(:,7)<=avp(1,7)+cfg.sim.experiment.duration_s,:);
truth=avp_to_imu(avp,cfg,false);
clear avp

%% Extract centripetal and tangential terms with the shared accelerometer model
systemCount=numel(cfg.system);
xIndices=zeros(1,systemCount);
for s=1:systemCount
    xIndices(s)=cfg.system(s).accIndex(1);
end
componentCfg=cfg;
componentCfg.err.acc.location=cfg.err.acc.internalLocation(:,xIndices);
componentCfg.err.acc.axes=repmat([1 0 0],systemCount,1);
for fieldCell={'scale','bias','noise','randomWalk'}
    field=fieldCell{1};
    componentCfg.err.acc.(field)=zeros(systemCount,1);
end
zeroMotion=zeros(size(truth.fb));
% Set origin force and angular acceleration to zero to isolate the x component of omega x (omega x r).
imu=struct('t',truth.t,'w',truth.wib_b,'wa',zeroMotion,'f',zeroMotion);
centripetal=acc_meas(imu,componentCfg);
% Set origin force and angular velocity to zero to isolate the x component of alpha x r.
imu.w=zeroMotion;
imu.wa=truth.alpha_b;
tangential=acc_meas(imu,componentCfg);
sampleCount=numel(truth.t);
rows=(1:cfg.sim.experiment.exportStride:sampleCount).';
if rows(end)~=sampleCount, rows(end+1)=sampleCount; end
result=struct('t',truth.t(rows)-truth.t(1));
for s=1:systemCount
    result.system(s).id=cfg.system(s).id;
    result.system(s).originForceX=truth.reference.system(s).fb(rows,1);
    result.system(s).tangentialX=tangential.f(rows,s);
    result.system(s).centripetalX=centripetal.f(rows,s);
end
clear truth imu tangential centripetal componentCfg zeroMotion xIndices rows

%% Export three columns per system for origin force, tangential, and centripetal terms in m/s^2
values=zeros(numel(result.t),1+3*systemCount);
values(:,1)=result.t;
names=cell(1,size(values,2));
names{1}='Time_s';
for s=1:systemCount
    columns=1+3*(s-1)+(1:3);
    values(:,columns)=[result.system(s).originForceX, ...
        result.system(s).tangentialX,result.system(s).centripetalX];
    names{columns(1)}=sprintf('System%dOriginForceX_m_s2',result.system(s).id);
    names{columns(2)}=sprintf('System%dTangentialX_m_s2',result.system(s).id);
    names{columns(3)}=sprintf('System%dCentripetalX_m_s2',result.system(s).id);
end
comparisonTable=array2table(values,'VariableNames',names);
excelFile=fullfile(figureDir,'figure18_force_acceleration_x.xlsx');
writetable(comparisonTable,excelFile,'Sheet','ForceAndAcceleration','WriteMode','replacefile');
clear values names comparisonTable
plot_figure18(result);
save(fullfile(figureDir,'figure18_force_acceleration_x.mat'),'result','-v7');
