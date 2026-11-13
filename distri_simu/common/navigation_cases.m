function result=navigation_cases(measurement,reference,cfg)
%NAVIGATION_CASES Run reconstruction and navigation for each system and calibration case.
%
% Inputs
%   measurement - Global t/gyro/acc observations in s, rad/s, and m/s^2.
%   reference - Main-origin and per-system reference states.
%   cfg - SI sensor/layout parameters, initialAlign, residual cases, and height-aiding setting.
%
% Outputs
%   result - inputRows, omittedTailSamples, and system(s).cases(c) containing name,
%       residualFraction, nav, and error. Navigation starts at row 2.
%
% Related functions
%   Calls calibration_cases, ins_init, ins_run, nav_err_eval, reconstruct_systems, rv2dcm.
%   Called by demo_main, experiment_navigation_cases.
n=numel(measurement.t);
rows=2:n;
assert(numel(rows)>=2,'dins:NavigationLength','At least three original observation epochs are required.');
cases=calibration_cases(cfg);
result=struct();
result.inputRows=rows;
result.omittedTailSamples=0;
for c=1:numel(cases)
    rec=reconstruct_systems(measurement,cases(c).array,cfg);
    for s=1:numel(cfg.system)
        switch cfg.sim.reconstruction.referencePoint
            case 'common_origin'
                origin=reference;
            case 'system_origin'
                origin=reference.system(s);
        end
        initial=struct('Cbn',rv2dcm(cfg.err.initialAlign)*origin.Cbn(:,:,2), ...
            'vn',origin.vn(2,:),'pos',origin.pos(2,:));
        ins=ins_init(initial,cfg);
        imu=struct('t',measurement.t(rows), ...
            'w',rec.system(s).wib_b(rows,:),'f',rec.system(s).fb(rows,:));
        if cfg.sim.navigation.heightAiding
            refh=origin.pos(rows,3);
        else
            refh=NaN(numel(rows),1);
        end
        nav=ins_run(ins,imu,refh);
        err=nav_err_eval(nav,origin,cfg.earth);
        result.system(s).id=cfg.system(s).id;
        result.system(s).cases(c)=struct('name',cases(c).name, ...
            'residualFraction',cases(c).residualFraction,'nav',nav,'error',err);
    end
end
end
