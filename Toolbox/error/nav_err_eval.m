function err=nav_err_eval(nav,ref,earth)
%NAV_ERR_EVAL Evaluate navigation error sequences and componentwise statistics.
%
% Inputs
%   nav - Solution t, Cbn, vn, and pos.
%   ref - Reference t/Cbn/vn/pos containing every nav.t epoch.
%   earth - Earth constants used for position-error conversion.
%
% Outputs
%   err - t, attErr (rad), velErr (m/s), posErr (m), Euler/geodetic differences, and maximum/RMS
%       error vectors.
%
% Related functions
%   Calls attitude_error321, state_err.
%   Called by navigation_cases.
[matched,idx]=ismember(nav.t,ref.t);
assert(all(matched),'dins:ReferenceTime','The reference trajectory must contain every navigation output time.');
N=numel(nav.t);
err.t=nav.t;
err.attErr=zeros(N,3);
err.attitudeMode='phi';
err.attitudeComponents={'PhiE','PhiN','PhiU'};
err.velErr=zeros(N,3);
err.posErr=zeros(N,3);

for k=1:N
    kr=idx(k);
    [err.attErr(k,:),err.velErr(k,:),err.posErr(k,:)]=state_err( ...
        nav.Cbn(:,:,k),nav.vn(k,:),nav.pos(k,:),ref.Cbn(:,:,kr), ...
        ref.vn(kr,:),ref.pos(kr,1),ref.pos(kr,2),ref.pos(kr,3),earth);
end

% 321 Euler-angle differences use heading/pitch/roll ordering.
err.eulerErr=attitude_error321(nav.Cbn,ref.Cbn(:,:,idx));
err.geodeticPosErr=nav.pos-ref.pos(idx,:);
err.geodeticPosErr(:,2)=atan2(sin(err.geodeticPosErr(:,2)),cos(err.geodeticPosErr(:,2)));

err.maxAtt=max(abs(err.attErr),[],1);
err.maxVel=max(abs(err.velErr),[],1);
err.maxPos=max(abs(err.posErr),[],1);
err.rmsAtt=sqrt(mean(err.attErr.^2,1));
err.rmsVel=sqrt(mean(err.velErr.^2,1));
err.rmsPos=sqrt(mean(err.posErr.^2,1));
end
