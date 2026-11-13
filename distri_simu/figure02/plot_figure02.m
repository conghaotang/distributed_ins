function fig = plot_figure02(avp, truth)
%PLOT_FIGURE02 Plot source and interpolated heading, latitude, and longitude.
%
% Inputs
%   avp - N-by-7 source trajectory, with angles in rad and time in s.
%   truth - Query t in s, plus yaw, latitude, and longitude arrays in rad.
%
% Outputs
%   fig - Interpolation comparison figure handle with time in s and angles in deg.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible', 'on', 'Color', 'w', 'Name', 'Figure 02 navigation');
titles = {'Yaw','Latitude and longitude'};
for group = 1:2
    ax = subplot(2,1,group, 'Parent', fig);
    if group == 1
        plot(ax, avp(:,7), rad2deg(avp(:,3)), '.', 'DisplayName', 'Source yaw');
        hold(ax, 'on');
        plot(ax, truth.t, rad2deg(truth.yaw), '-', 'DisplayName', 'Reconstructed yaw');
        ylabel(ax, 'Yaw (°)');
    else
        plot(ax, avp(:,7), rad2deg(avp(:,4)), '.', 'DisplayName', 'Source latitude');
        hold(ax, 'on');
        plot(ax, avp(:,7), rad2deg(avp(:,5)), '.', 'DisplayName', 'Source longitude');
        plot(ax, truth.t, rad2deg(truth.latitude), '-', 'DisplayName', 'Reconstructed latitude');
        plot(ax, truth.t, rad2deg(truth.longitude), '-', 'DisplayName', 'Reconstructed longitude');
        ylabel(ax, 'Latitude / longitude (°)');
    end
    title(ax, titles{group}); grid(ax, 'on');
    legend(ax, 'Location', 'best');
    xlim(ax, [truth.t(1), truth.t(end)]);
    if group == 2, xlabel(ax, 'Time / s'); end
end
end
