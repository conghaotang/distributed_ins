function fig = plot_figure03(truth)
%PLOT_FIGURE03 Plot ideal body angular velocity and angular acceleration.
%
% Inputs
%   truth - t in s, wib_b in rad/s, and alpha_b in rad/s^2, with N-by-3 motion arrays.
%
% Outputs
%   fig - Two-panel figure handle with time in h, rates in deg/s, and accelerations in deg/s^2.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible', 'on', 'Color', 'w', 'Name', 'Figure 03 body angular motion');
subplot(2,1,1); plot(truth.t/3600, rad2deg(truth.wib_b)); grid on; ylabel('\omega (°/s)');
legend('x','y','z', 'Location', 'best'); title('Figure 03: body angular velocity');
subplot(2,1,2); plot(truth.t/3600, rad2deg(truth.alpha_b)); grid on; ylabel('\alpha (°/s^2)');
xlabel('Time / h'); legend('x','y','z', 'Location', 'best');
end
