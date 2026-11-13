function C=q2dcm(q)
%Q2DCM Convert a scalar-first Hamilton quaternion to a rotation matrix.
%
% Inputs
%   q - Four-element quaternion [q0;q1;q2;q3], normalized internally.
%
% Outputs
%   C - 3-by-3 direction cosine matrix with the same rotation direction as q.
%
% Related functions
%   Uses the same quaternion convention as dcm2q.
%   Calls skew.
q=q(:);
qNorm=norm(q);
q=q/qNorm;

qs=q(1);
qv=q(2:4);
C=(qs^2-qv.'*qv)*eye(3)+2*(qv*qv.')+2*qs*skew(qv);
end
