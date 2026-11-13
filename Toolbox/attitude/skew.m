function K=skew(v)
%SKEW Construct cross-product matrices.
%
% Inputs
%   v - Three-element vector or N-by-3 vector sequence.
%
% Outputs
%   K - 3-by-3 or 3-by-3-by-N matrices satisfying K*u = v cross u.
%
% Related functions
%   Called by attitude_inter, q2dcm.
if isvector(v)
    v=reshape(v,1,3);
end
n=size(v,1);
K=zeros(3,3,n);
K(1,2,:)=-v(:,3);
K(1,3,:)=v(:,2);
K(2,1,:)=v(:,3);
K(2,3,:)=-v(:,1);
K(3,1,:)=-v(:,2);
K(3,2,:)=v(:,1);
end
