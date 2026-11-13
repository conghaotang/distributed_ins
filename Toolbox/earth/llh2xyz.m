function reb_e=llh2xyz(B,L,H,earth)
%LLH2XYZ Convert geodetic coordinates to ECEF Cartesian positions.
%
% Inputs
%   B - Latitude in rad, scalar or N-element vector.
%   L - Longitude in rad, scalar or N-element vector.
%   H - Ellipsoidal height in m, scalar or N-element vector.
%   earth - Ellipsoid parameters a (m) and e2. Scalars expand to the common batch length.
%
% Outputs
%   reb_e - N-by-3 ECEF [X Y Z] positions in m.
%
% Related functions
%   Paired with xyz2llh for geodetic/ECEF conversion.
%   Called by avp_to_imu.
n=max([numel(B),numel(L),numel(H)]);

if isscalar(B), B=repmat(B,n,1); else, B=B(:); end
if isscalar(L), L=repmat(L,n,1); else, L=L(:); end
if isscalar(H), H=repmat(H,n,1); else, H=H(:); end

sB=sin(B);
cB=cos(B);
sL=sin(L);
cL=cos(L);
RN=earth.a./sqrt(1-earth.e2*sB.^2);

reb_e=[(RN+H).*cB.*cL, ...
       (RN+H).*cB.*sL, ...
       ((1-earth.e2)*RN+H).*sB];
end
