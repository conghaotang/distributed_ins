function [attErr,velErr,posErr]=state_err( ...
    Cbn,vn,pos,CbnRef,vnRef,BRef,LRef,HRef,earth)
%STATE_ERR Calculate ENU misalignment, velocity, and position errors at one epoch.
%
% Inputs
%   Cbn - Estimated 3-by-3 body-to-navigation matrix.
%   vn - Estimated three-element ENU velocity in m/s.
%   pos - Estimated [B L H] in rad, rad, m.
%   CbnRef - Reference 3-by-3 body-to-navigation matrix.
%   vnRef - Reference ENU velocity in m/s.
%   BRef - Reference latitude in rad.
%   LRef - Reference longitude in rad.
%   HRef - Reference height in m.
%   earth - Ellipsoid constants a and e2.
%
% Outputs
%   attErr - 1-by-3 small-angle [PhiE PhiN PhiU] misalignment in rad.
%   velErr - 1-by-3 estimated-minus-reference ENU velocity in m/s.
%   posErr - 1-by-3 ENU distance error in m.
%
% Related functions
%   Called by nav_err_eval.
Ce=Cbn*CbnRef.';
attErr=0.5*[Ce(2,3)-Ce(3,2), ...
            Ce(3,1)-Ce(1,3), ...
            Ce(1,2)-Ce(2,1)];
velErr=(vn(:)-vnRef(:)).';

a=earth.a;
e2=earth.e2;
s=sin(BRef);
RN=a/sqrt(1-e2*s^2);
RM=a*(1-e2)/(1-e2*s^2)^(3/2);
dL=atan2(sin(pos(2)-LRef),cos(pos(2)-LRef));
posErr=[dL*(RN+HRef)*cos(BRef), ...
        (pos(1)-BRef)*(RM+HRef), ...
        pos(3)-HRef];
end
