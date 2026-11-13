function truth=avp_to_imu(avp,cfg,applyErrors,options)
%AVP_TO_IMU Generate ideal body motion and optional distributed sensor observations.
%
% Inputs
%   avp - N-by-7 [theta phi psi B L H t], with at least four increasing time nodes. Angles use
%       rad, height m, and time s. Attitude is 321.
%   cfg - SI sensor, Earth, sampling, and system-layout configuration.
%   applyErrors - Optional logical flag, default true, enabling sensor observation generation.
%   options - Optional structure with query times options.t. Default spacing is cfg.dt.
%       Observation generation requires uniform cfg.dt spacing.
%
% Outputs
%   truth - Trajectory structure with t, att, pos, Cbn, analytic derivatives, wib_b (rad/s),
%       alpha_b (rad/s^2), fb (m/s^2), Earth terms, pp, and reference.
%   truth.measurement - Generated t/gyro/acc arrays when applyErrors is true.
%   truth.system - Per-system observations when applyErrors is true.
%
% Related functions
%   Calls Cen, EvalSplineAll, acc_meas, attitude_inter, data_interp, gyro_meas and other
%   helpers.
%   Called by demo_main.
%   Called by experiment main scripts.
if nargin<3
    applyErrors=true;
end
if nargin<4
    options=struct();
end
assert(size(avp,2)==7 && size(avp,1)>=4, ...
    'dins:AVPShape','AVP must be an N-by-7 matrix with at least four rows.');
assert(all(isfinite(avp),'all') && all(diff(avp(:,7))>0), ...
    'dins:AVPTime','AVP values must be finite and timestamps must be strictly increasing.');
if isfield(options,'t')
    t=options.t(:);
else
    count=floor((avp(end,7)-avp(1,7))/cfg.dt);
    t=avp(1,7)+(0:count)'*cfg.dt;
end
assert(all(isfinite(t)) && all(diff(t)>0) ...
    && t(1)>=avp(1,7) && t(end)<=avp(end,7), ...
    'dins:QueryTime','Query times must be finite, strictly increasing, and within the trajectory interval.');
pp=data_interp(avp);
fields={'theta','phi','psi','B','L','H'};
n=numel(t);
value=zeros(n,6); d1=zeros(n,6); d2=zeros(n,6);
for j=1:6
    [value(:,j),d1(:,j),d2(:,j)]=EvalSplineAll(pp.(fields{j}),t);
end
B=value(:,4); L=value(:,5); H=value(:,6);
dB=d1(:,4); dL=d1(:,5); dH=d1(:,6);
ddB=d2(:,4); ddL=d2(:,5); ddH=d2(:,6);
earth=cfg.earth;
sB=sin(B); cB=cos(B);
den=1-earth.e2*sB.^2;
RN=earth.a./sqrt(den);
RM=earth.a*(1-earth.e2)./den.^(3/2);
RN_dot=earth.a*earth.e2*sB.*cB.*dB./den.^(3/2);
RM_dot=3*earth.a*(1-earth.e2)*earth.e2*sB.*cB.*dB./den.^(5/2);
% Compute ground velocity and its analytic time derivative.
vn=[(RN+H).*dL.*cB,(RM+H).*dB,dH];
vEdot=(RN_dot+dH).*dL.*cB+(RN+H).*ddL.*cB ...
    -(RN+H).*dL.*dB.*sB;
vNdot=(RM_dot+dH).*dB+(RM+H).*ddB;
vdot=[vEdot,vNdot,ddH];
% Compute Earth and transport rates and their derivatives in ENU coordinates.
wie_n=[zeros(n,1),earth.wie*cB,earth.wie*sB];
wen_n=[-dB,dL.*cB,dL.*sB];
wie_dot_n=[zeros(n,1),-earth.wie*dB.*sB,earth.wie*dB.*cB];
wen_dot_n=[-ddB,ddL.*cB-dL.*dB.*sB,ddL.*sB+dL.*dB.*cB];
[Cbn,dCbn,ddCbn,wnb_b,alpha_nb_b]=attitude_inter(pp,t);
Cnb=pagetranspose(Cbn);
win_b=reshape(pagemtimes(Cnb,permute(wie_n+wen_n,[2 3 1])),3,n).';
wib_b=win_b+wnb_b;
% Include the derivative of the time-varying navigation-to-body transformation.
alpha_b=reshape(pagemtimes(Cnb, ...
    permute(wie_dot_n+wen_dot_n,[2 3 1])),3,n).' ...
    +alpha_nb_b-cross(wnb_b,win_b,2);
gn=[zeros(n,2),-normal_g(B,H,earth)];
f_n=vdot+cross(2*wie_n+wen_n,vn,2)-gn;
fb=reshape(pagemtimes(Cnb,permute(f_n,[2 3 1])),3,n).';
% g_grav=gn+c, where c is centripetal acceleration due to Earth rotation.
centripetal_n=earth.wie^2*(RN+H).*[zeros(n,1),sB.*cB,-cB.^2];
g_grav_n=gn+centripetal_n;
aib_b=fb+reshape(pagemtimes(Cnb,permute(g_grav_n,[2 3 1])),3,n).';
pos=value(:,4:6);
Cne=pagetranspose(Cen(pos));
r_eb_e=llh2xyz(B,L,H,earth);
v_eb_e=reshape(pagemtimes(Cne,permute(vn,[2 3 1])),3,n).';
truth=struct('t',t,'avp',avp,'att',value(:,1:3),'pos',pos, ...
    'att_d1',d1(:,1:3),'att_d2',d2(:,1:3), ...
    'pos_d1',d1(:,4:6),'pos_d2',d2(:,4:6), ...
    'Cbn',Cbn,'dCbn',dCbn,'ddCbn',ddCbn, ...
    'wib_b',wib_b,'alpha_b',alpha_b,'fb',fb, ...
    'v_eb_n',vn,'v_eb_dot_n',vdot,'v_eb_e',v_eb_e,'r_eb_e',r_eb_e, ...
    'a_ib_b',aib_b,'omega_ie_n',wie_n,'omega_en_n',wen_n, ...
    'omega_in_dot_n',wie_dot_n+wen_dot_n,'omega_nb_b',wnb_b, ...
    'omega_nb_dot_b',alpha_nb_b,'RN',RN,'RM',RM, ...
    'RN_dot',RN_dot,'RM_dot',RM_dot,'gn',gn,'g_grav_n',g_grav_n, ...
    'pp',pp,'cfg',cfg,'sourceAttitudeConvention','321');
truth.reference=refere_sys(truth,cfg);
if applyErrors
    assert(n>=2 && max(abs(diff(t)-cfg.dt))<=1e-9*cfg.dt+8*eps(max(abs(t))), ...
        'dins:MeasurementTime','Sensor measurements must be sampled uniformly at cfg.dt.');
    imu=struct('t',t,'w',wib_b,'wa',alpha_b,'f',fb);
    imu=acc_meas(imu,cfg);
    imu=gyro_meas(imu,cfg);
    measurement=struct('t',t,'gyro',imu.w,'acc',imu.f);
    truth.measurement=measurement;
    truth.system=split_system_measurements(measurement,cfg);
end
end
