function q=dcm2q(C)
%DCM2Q Convert rotation matrices to scalar-first Hamilton unit quaternions.
%
% Inputs
%   C - 3-by-3 or 3-by-3-by-N direction cosine matrices.
%
% Outputs
%   q - 4-by-N quaternions ordered [q0;q1;q2;q3], normalized with q0 >= 0.
%
% Related functions
%   Paired with q2dcm for quaternion/matrix conversion.
pageNumber=size(C,3);
q=zeros(4,pageNumber);

for k=1:pageNumber
    Ck=C(:,:,k);
    traceC=trace(Ck);

    if traceC>0
        q0=sqrt(1+traceC)/2;
        qv=[Ck(3,2)-Ck(2,3); ...
            Ck(1,3)-Ck(3,1); ...
            Ck(2,1)-Ck(1,2)]/(4*q0);
    else
        [~,maxIndex]=max(diag(Ck));
        qv=zeros(3,1);

        if maxIndex==1
            qv(1)=sqrt(1+Ck(1,1)-Ck(2,2)-Ck(3,3))/2;
            q0=(Ck(3,2)-Ck(2,3))/(4*qv(1));
            qv(2)=(Ck(1,2)+Ck(2,1))/(4*qv(1));
            qv(3)=(Ck(1,3)+Ck(3,1))/(4*qv(1));
        elseif maxIndex==2
            qv(2)=sqrt(1-Ck(1,1)+Ck(2,2)-Ck(3,3))/2;
            q0=(Ck(1,3)-Ck(3,1))/(4*qv(2));
            qv(1)=(Ck(1,2)+Ck(2,1))/(4*qv(2));
            qv(3)=(Ck(2,3)+Ck(3,2))/(4*qv(2));
        else
            qv(3)=sqrt(1-Ck(1,1)-Ck(2,2)+Ck(3,3))/2;
            q0=(Ck(2,1)-Ck(1,2))/(4*qv(3));
            qv(1)=(Ck(1,3)+Ck(3,1))/(4*qv(3));
            qv(2)=(Ck(2,3)+Ck(3,2))/(4*qv(3));
        end
    end

    q(:,k)=[q0;qv];
    q(:,k)=q(:,k)/norm(q(:,k),2);
    if q(1,k)<0
        q(:,k)=-q(:,k);
    end
end
end
