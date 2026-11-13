function X = array_solve(Y,B,Q)
%ARRAY_SOLVE Reconstruct three-axis motion by covariance-weighted least squares.
%
% Inputs
%   Y - N-by-M observation array.
%   B - M-by-3 observation matrix with full column rank.
%   Q - Symmetric positive-definite M-by-M covariance. eye(M) selects equal weighting.
%
% Outputs
%   X - N-by-3 reconstructed motion in the units of Y.
%
% Related functions
%   Called by array_reconstruct.
L=chol(Q,'lower');
X=((L\B)\(L\Y.')).';
end
