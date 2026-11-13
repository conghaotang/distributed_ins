function reference=refere_sys(truth,cfg)
%REFERE_SYS Translate main-origin reference motion to configured subsystem origins.
%
% Inputs
%   truth - Main-origin trajectory containing t, pos, att, Cbn, r_eb_e, v_eb_e, v_eb_n, wib_b,
%       alpha_b, and fb.
%   cfg - SI Earth parameters and cfg.system origin offsets and sensor indices.
%
% Outputs
%   reference - Main-origin t, pos, vn, Cbn, att, ECEF motion, wib_b, alpha_b, and fb.
%   reference.system - Per-origin reference fields in each local ENU frame, using fixed b-frame
%       lever arms and shared gravity.
%
% Related functions
%   Calls Cen, dcm2elur, xyz2llh.
%   Called by avp_to_imu.
n=numel(truth.t);
reference=struct('t',truth.t,'pos',truth.pos,'vn',truth.v_eb_n, ...
    'Cbn',truth.Cbn,'att',truth.att,'r_eb_e',truth.r_eb_e, ...
    'v_eb_e',truth.v_eb_e,'wib_b',truth.wib_b, ...
    'alpha_b',truth.alpha_b,'fb',truth.fb);

% Share C_b^e across systems and translate ECEF velocity using omega_eb^b.
Cbe=pagemtimes(pagetranspose(Cen(truth.pos)),truth.Cbn);
wie_b=reshape(pagemtimes(pagetranspose(Cbe),[0;0;cfg.earth.wie]),3,n).';
web_b=truth.wib_b-wie_b;
clear wie_b

reference.system=cfg.system;
for s=1:numel(cfg.system)
    lever_b=cfg.system(s).lever_b;
    r_b=repmat(lever_b.',n,1);
    % Translate r_eb_s^e=r_eb^e+C_b^e*r_bb_s^b, then recover each origin's geodetic coordinates.
    position_e=truth.r_eb_e+reshape(pagemtimes(Cbe,lever_b),3,n).';
    position=xyz2llh(position_e,cfg.earth);
    CenLocal=Cen(position);
    CbnLocal=pagemtimes(CenLocal,Cbe);
    [theta,phi,psi]=dcm2elur(CbnLocal,cfg.tol.dcm);

    % v_eb_s^e=v_eb^e+C_b^e*[omega_eb^b×]*r_bb_s^b。
    velocityOffset_b=cross(web_b,r_b,2);
    velocity_e=truth.v_eb_e+reshape(pagemtimes( ...
        Cbe,permute(velocityOffset_b,[2 3 1])),3,n).';
    reference.system(s).t=truth.t;
    reference.system(s).pos=position;
    reference.system(s).vn=reshape(pagemtimes( ...
        CenLocal,permute(velocity_e,[2 3 1])),3,n).';
    reference.system(s).Cbn=CbnLocal;
    reference.system(s).att=[theta,phi,psi];
    reference.system(s).r_eb_e=position_e;
    reference.system(s).v_eb_e=velocity_e;
    reference.system(s).wib_b=truth.wib_b;
    reference.system(s).alpha_b=truth.alpha_b;
    % Use the shared-gravitational-field approximation consistently with measurement generation.
    reference.system(s).fb=truth.fb ...
        +cross(truth.wib_b,cross(truth.wib_b,r_b,2),2) ...
        +cross(truth.alpha_b,r_b,2);
end
end
