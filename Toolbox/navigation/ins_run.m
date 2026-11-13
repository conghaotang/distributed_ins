function nav=ins_run(ins,imu,refh)
%INS_RUN Navigate a full observation sequence using configurable subsample blocks.
%
% Inputs
%   ins - Initialized navigation state including subs.
%   imu - At least two uniformly spaced t values (s), with N-by-3 w (rad/s) and f (m/s^2).
%   refh - Optional N-by-1 reference heights (m), aligned with imu.t. Default values are NaN.
%
% Outputs
%   nav - t at initial/update/final epochs, Cbn (3-by-3-by-Nout), vn (Nout-by-3, m/s), and pos
%       (Nout-by-3, rad/rad/m).
%
% Related functions
%   Calls ins_step.
%   Called by navigation_cases.
n=numel(imu.t);
assert(n>=2,'dins:SampleCount','Navigation requires at least two observation epochs.');
dt=diff(imu.t(:));
assert(all(isfinite(imu.t)) && all(dt>0) ...
    && max(abs(dt-dt(1)))<=1e-9*dt(1)+8*eps(max(abs(imu.t))) ...
    && isequal(size(imu.w),[n,3]) && isequal(size(imu.f),[n,3]) ...
    && all(isfinite(imu.w),'all') && all(isfinite(imu.f),'all'), ...
    'dins:IMUInput','IMU observations must be finite N-by-3 arrays with uniformly spaced, strictly increasing timestamps.');
if nargin<3
    refh=NaN(n,1);
end
refh=refh(:);
if isfinite(refh(1)), ins.pos(3)=refh(1); end
rows=1:ins.subs:n;
if rows(end)~=n
    rows(end+1)=n;
end
count=numel(rows);
nav.t=imu.t(rows);
nav.t=nav.t(:);
nav.Cbn=zeros(3,3,count);
nav.vn=zeros(count,3);
nav.pos=zeros(count,3);
nav.Cbn(:,:,1)=ins.Cbn;
nav.vn(1,:)=ins.vn.';
nav.pos(1,:)=ins.pos.';
for j=2:count
    k=rows(j-1);
    k2=rows(j);
    block=struct('t',imu.t(k:k2),'w',imu.w(k:k2,:),'f',imu.f(k:k2,:));
    ins=ins_step(ins,block,refh(k2));
    nav.Cbn(:,:,j)=ins.Cbn;
    nav.vn(j,:)=ins.vn.';
    nav.pos(j,:)=ins.pos.';
end
end
