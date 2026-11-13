function llh=xyz2llh(reb_e,earth)
%XYZ2LLH Convert ECEF Cartesian positions to geodetic coordinates.
%
% Inputs
%   reb_e - Three-element vector, N-by-3, or 3-by-N ECEF positions in m.
%   earth - Ellipsoid parameters a (m) and e2.
%
% Outputs
%   llh - N-by-3 [B L H] in rad, rad, m.
%
% Related functions
%   Paired with llh2xyz for ECEF/geodetic conversion.
%   Called by refere_sys.
if isvector(reb_e)
    reb_e=reshape(reb_e,1,3);
elseif size(reb_e,2)==3
    % Already N-by-3, with one point per row.
elseif size(reb_e,1)==3
    reb_e=reb_e.';
end

a=earth.a;
e2=earth.e2;
b=a*sqrt(1-e2);
ep2=(a^2-b^2)/b^2;

X=reb_e(:,1);
Y=reb_e(:,2);
Z=reb_e(:,3);
p=hypot(X,Y);
L=atan2(Y,X);

theta=atan2(a*Z,b*p);
sTheta=sin(theta);
cTheta=cos(theta);
B=atan2(Z+ep2*b*sTheta.^3,p-e2*a*cTheta.^3);

sB=sin(B);
cB=cos(B);
RN=a./sqrt(1-e2*sB.^2);
H=p./cB-RN;

% Near the poles, calculate height from Z to avoid p/cos(B) becoming 0/0.
pole=abs(cB)<sqrt(eps);
if any(pole)
    H(pole)=abs(Z(pole))-b;
end

llh=[B,L,H];
end
