function eulerUnw = unwrapEuler(eulerRaw)
%UNWRAPEULER Unwrap roll and yaw while retaining pitch.
%
% Inputs
%   eulerRaw - N-by-3 [phi theta psi] in rad. Reorder AVP columns with (:,[2 1 3]).
%
% Outputs
%   eulerUnw - N-by-3 angles in the same order and units, with continuous phi and psi.
%
% Related functions
%   Calls unwrap2pi.
%   Called by experiment main scripts.
eulerUnw=eulerRaw;
eulerUnw(:,1)=unwrap2pi(eulerRaw(:,1));
eulerUnw(:,3)=unwrap2pi(eulerRaw(:,3));
end
