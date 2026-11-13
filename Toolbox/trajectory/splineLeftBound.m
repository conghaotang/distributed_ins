function ppCell=splineLeftBound(t,Y)
%SPLINELEFTBOUND Construct Not-a-Knot cubic splines on shared nonuniform nodes.
%
% Inputs
%   t - N-by-1 increasing node times, with N >= 4.
%   Y - N-by-K channel values.
%
% Outputs
%   ppCell - K-by-1 cell array of MATLAB piecewise polynomials.
%
% Related functions
%   Called by data_interp.
t=t(:);
n=numel(t);
assert(n>=4 && size(Y,1)==n && all(diff(t)>0), ...
    'dins:SplineNodes','Not-a-Knot interpolation requires at least four strictly increasing nodes.');
h=diff(t);
hp=h(1:end-1);
hc=h(2:end);
den=hp+hc;
mu=hp./den;
eta=hc./den;
slope=diff(Y,1,1)./h;
D=6*(slope(2:end,:)-slope(1:end-1,:))./den;
r=(2:n-1)';
A=sparse([r;r;r],[r-1;r;r+1],[mu;2*ones(n-2,1);eta],n,n);
A(1,1:3)=[h(2),-(h(1)+h(2)),h(1)];
A(n,n-2:n)=[h(end),-(h(end-1)+h(end)),h(end-1)];
rhs=zeros(n,size(Y,2));
rhs(2:n-1,:)=D;
M=A\rhs;
a3=diff(M,1,1)./(6*h);
a2=M(1:end-1,:)/2;
a1=slope-h.*(2*M(1:end-1,:)+M(2:end,:))/6;
ppCell=cell(size(Y,2),1);
for j=1:size(Y,2)
    ppCell{j}=mkpp(t.',[a3(:,j),a2(:,j),a1(:,j),Y(1:end-1,j)]);
end
end
