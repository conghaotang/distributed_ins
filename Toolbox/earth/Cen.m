function C=Cen(llh)
%CEN Construct ECEF-to-local-ENU direction cosine matrices.
%
% Inputs
%   llh - [B L H] as a three-element vector, N-by-3, or 3-by-N array. Units are rad, rad, m.
%
% Outputs
%   C - 3-by-3-by-N matrices satisfying v_n = C*v_e.
%
% Related functions
%   Called by avp_to_imu, refere_sys.
if isvector(llh)
    llh=reshape(llh,1,3);
elseif size(llh,2)==3
    % Already N-by-3, with one point per row.
elseif size(llh,1)==3
    llh=llh.';
end

B=llh(:,1);
L=llh(:,2);
n=size(llh,1);
sB=reshape(sin(B),1,1,n);
cB=reshape(cos(B),1,1,n);
sL=reshape(sin(L),1,1,n);
cL=reshape(cos(L),1,1,n);

C=zeros(3,3,n);
C(1,1,:)=-sL;
C(1,2,:)=cL;
C(2,1,:)=-sB.*cL;
C(2,2,:)=-sB.*sL;
C(2,3,:)=cB;
C(3,1,:)=cB.*cL;
C(3,2,:)=cB.*sL;
C(3,3,:)=sB;
end
