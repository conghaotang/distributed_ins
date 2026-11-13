function rec = array_reconstruct(meas, array)
%ARRAY_RECONSTRUCT Recover body rates, angular acceleration, and lever-arm-corrected force.
%
% Inputs
%   meas - t is N-by-1 (s), gyro is N-by-Mg (rad/s), and acc is N-by-Ma (m/s^2).
%   array - gyro/acc contain axes, direct gains in scale, biases, and Q. acc.lever is Ma-by-3 in
%       m.
%
% Outputs
%   rec - t, N-by-3 wib_b (rad/s), alpha_b (rad/s^2), fb (m/s^2), and N-by-1 valid. First
%       alpha_b/fb rows are NaN and valid(1) is false.
%
% Related functions
%   Calls array_calibration, array_solve.
%   Called by reconstruct_systems.
t = double(meas.t(:));
gyroY = double(meas.gyro);
accY = double(meas.acc);
n = numel(t);

[Bg, bg, Qg] = array_calibration(array.gyro);
[Ba, ba, Qa] = array_calibration(array.acc);

w = array_solve(gyroY - repmat(bg.', n, 1), Bg, Qg);

alpha = nan(n, 3);
if n > 1
    dt = diff(t);
    alpha(2:end, :) = bsxfun(@rdivide, diff(w, 1, 1), dt);
end

f = nan(n, 3);
valid = false(n, 1);
lever = array.acc.lever;
if n > 1
    % Batch the sensitive-axis lever-arm projections and reuse one weighted solve.
    wk=w(2:end,:);
    ak=alpha(2:end,:);
    leverTerm=(wk*Ba.').*(wk*lever.') ...
        -sum(wk.^2,2).*sum(Ba.*lever,2).' ...
        +ak*cross(lever,Ba,2).';
    rhs=accY(2:end,:)-ba.'-leverTerm;
    f(2:end,:)=array_solve(rhs,Ba,Qa);
    valid(2:end)=true;
end

rec = struct('t', t, 'wib_b', w, 'alpha_b', alpha, 'fb', f, ...
             'valid', valid);
end
