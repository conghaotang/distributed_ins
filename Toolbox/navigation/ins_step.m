function ins=ins_step(ins,imu,refh)
%INS_STEP Update attitude, velocity, and position over one IMU block.
%
% Inputs
%   ins - Navigation state at the block start.
%   imu - (Ns+1)-by-1 uniformly spaced endpoint times and (Ns+1)-by-3 w (rad/s) and f (m/s^2),
%       with 1 <= Ns <= 6.
%   refh - Optional scalar reference height at the block end (m). NaN or omission selects
%       vertical integration.
%
% Outputs
%   ins - Navigation state at the block end. Finite refh sets height and derives vertical
%       velocity from its change.
%
% Related functions
%   Calls ins_cnscl, nav_rate, rv2dcm.
%   Called by ins_run.
if nargin<3
    refh=NaN;
end
dt=imu.t(2)-imu.t(1);
inc=[0.5*(imu.w(1:end-1,:)+imu.w(2:end,:))*dt, ...
     0.5*(imu.f(1:end-1,:)+imu.f(2:end,:))*dt];
[phim,dvbm]=ins_cnscl(inc);
nts=imu.t(end)-imu.t(1);

Cbn=ins.Cbn;
vn=ins.vn;
pos=ins.pos;
B=pos(1); L=pos(2); H=pos(3);

eth=nav_rate(B,H,vn,ins.earth);Bmid=B+0.5*nts*vn(2)/(eth.RM+H);
eth=nav_rate(Bmid,H,vn,ins.earth);winN=eth.wieN+eth.wenN;

fn=rv2dcm(-0.5*winN*nts)*Cbn*(dvbm/nts);
gn=[0;0;-eth.g];
an=fn-cross(2*eth.wieN+eth.wenN,vn)+gn;
vnMid=vn+0.5*an*nts;
fixH=isfinite(refh);
if fixH
    vnMid(3)=0;
end

eth=nav_rate(Bmid,H,vnMid,ins.earth);
winN=eth.wieN+eth.wenN;
fn=rv2dcm(-0.5*winN*nts)*Cbn*(dvbm/nts);
Cbn=rv2dcm(-winN*nts)*Cbn*rv2dcm(phim);

an=fn-cross(2*eth.wieN+eth.wenN,vnMid)+gn;
vn1=vn+an*nts;
if fixH
    vn1(3)=(refh-H)/nts;
end
vnPos=0.5*(vn+vn1);

B1=B+nts*vnPos(2)/(eth.RM+H);
L1=L+nts*vnPos(1)/((eth.RN+H)*cos(Bmid));
if fixH
    H1=refh;
else
    H1=H+nts*vnPos(3);
end
ins.Cbn=Cbn;
ins.vn=vn1;
ins.pos=[B1;L1;H1];
end
