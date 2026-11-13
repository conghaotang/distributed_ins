function error = attitude_error321(Cbn,CbnRef)
%ATTITUDE_ERROR321 Calculate heading, pitch, and roll differences.
%
% Inputs
%   Cbn - Estimated 3-by-3-by-N body-to-navigation matrices.
%   CbnRef - Reference matrices of the same size.
%
% Outputs
%   error - N-by-3 [Heading Pitch Roll] differences in rad, with heading/roll wrapped.
%
% Related functions
%   Calls dcm2elur.
%   Called by nav_err_eval.
[pitch,roll,heading]=dcm2elur(Cbn);
[pitchRef,rollRef,headingRef]=dcm2elur(CbnRef);
error=[heading-headingRef,pitch-pitchRef,roll-rollRef];
error(:,[1 3])=atan2(sin(error(:,[1 3])),cos(error(:,[1 3])));
end
