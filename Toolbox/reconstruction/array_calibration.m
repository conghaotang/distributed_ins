function [B, b, Q] = array_calibration(sensor)
%ARRAY_CALIBRATION Assemble one sensor group's observation matrix, bias, and covariance.
%
% Inputs
%   sensor - axes is M-by-3, scale contains M direct gains, bias has M entries, and Q is M-by-M.
%
% Outputs
%   B - M-by-3 dimensionless matrix of gain-weighted sensing axes.
%   b - M-by-1 bias vector in rad/s or m/s^2.
%   Q - M-by-M observation covariance in squared measurement units.
%
% Related functions
%   Called by array_reconstruct.
B=sensor.axes.*sensor.scale(:);
b=sensor.bias(:);
Q=sensor.Q;
end
