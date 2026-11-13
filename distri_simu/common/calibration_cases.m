function cases = calibration_cases(cfg,systemIndex)
%CALIBRATION_CASES Construct compensation parameters for the configured residual fractions.
%
% Inputs
%   cfg - SI sensor parameters plus sim.calibration and sim.reconstruction settings.
%   systemIndex - Optional cfg.system index. Omission selects the complete sensor array.
%
% Outputs
%   cases - Case structures with name, residualFraction, and array. Arrays contain estimated
%       axes, direct gains, biases, Q, and lever arms in m.
%
% Related functions
%   Called by navigation_cases.
%   Called by experiment main scripts.
fractions=cfg.sim.calibration.residualFractions;
cases=repmat(struct('name','','residualFraction',0,'array',struct()),1,numel(fractions));
for c=1:numel(fractions)
    r=fractions(c);
    cases(c).name=cfg.sim.calibration.names{c};
    cases(c).residualFraction=r;
    for sensorCell={'gyro','acc'}
        sensor=sensorCell{1};
        actual=cfg.err.(sensor);
        if nargin==2
            % Parameter rows and observation columns use matching, sensor-specific indices.
            j=cfg.system(systemIndex).([sensor,'Index']);
            actual.nominalAxes=actual.nominalAxes(j,:);
            actual.Q=actual.Q(j,j);
            for fieldCell={'directionError','directionErrorBearing','scale','bias','noise'}
                field=fieldCell{1};
                actual.(field)=actual.(field)(j);
            end
            if strcmp(sensor,'acc')
                switch cfg.sim.reconstruction.referencePoint
                    case 'common_origin'
                        actual.location=actual.location(:,j);
                    case 'system_origin'
                        actual.location=cfg.err.acc.internalLocation(:,j);
                end
            end
        end
        axesHat=zeros(size(actual.nominalAxes));
        for j=1:size(axesHat,1)
            h=actual.nominalAxes(j,:).';
            [~,k]=min(abs(h));
            e=zeros(3,1); e(k)=1;
            q1=cross(h,e); q1=q1/norm(q1);
            q2=cross(h,q1);
            direction=cos(actual.directionErrorBearing(j))*q1 ...
                +sin(actual.directionErrorBearing(j))*q2;
            angleHat=(1-r)*actual.directionError(j);
            axesHat(j,:)=(cos(angleHat)*h+sin(angleHat)*direction).';
        end
        estimated=struct('axes',axesHat,'scale',1+(1-r)*actual.scale, ...
            'bias',(1-r)*actual.bias, ...
            'Q',actual.Q);
        if strcmp(sensor,'acc'), estimated.lever=actual.location.'; end
        cases(c).array.(sensor)=estimated;
    end
end
end
