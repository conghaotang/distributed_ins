function fig = plot_figure00(longitude_deg, latitude_deg)
%PLOT_FIGURE00 Plot a longitude-latitude trajectory.
%
% Inputs
%   longitude_deg - N-element longitude array in deg.
%   latitude_deg - N-element latitude array in deg.
%
% Outputs
%   fig - Trajectory figure handle with approximately equal horizontal distance scales.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible', 'on', 'Color', 'w', 'Name', 'Figure 00 trajectory');
ax = axes('Parent', fig);
plot(ax, longitude_deg, latitude_deg, '-', 'LineWidth', 1.5, ...
    'Color', [0 0.4470 0.7410], 'DisplayName', 'Trajectory');
hold(ax, 'on');
plot(ax, longitude_deg(1), latitude_deg(1), 'o', ...
    'MarkerFaceColor', [0.2 0.6 0.2], 'MarkerEdgeColor', [0.2 0.6 0.2], ...
    'DisplayName', 'Start');
plot(ax, longitude_deg(end), latitude_deg(end), 's', ...
    'MarkerFaceColor', [0.85 0.2 0.2], 'MarkerEdgeColor', [0.85 0.2 0.2], ...
    'DisplayName', 'End');
grid(ax, 'on');
box(ax, 'on');
xlabel(ax, 'Longitude (deg)');
ylabel(ax, 'Latitude (deg)');
% Scale longitude by the mean latitude for approximately equal horizontal distance scales.
daspect(ax, [1/cosd(mean(latitude_deg)), 1, 1]);
set(ax, 'FontName', 'Times New Roman', 'FontSize', 10);
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;
legend(ax, 'Location', 'best', 'FontName', 'Times New Roman', 'FontSize', 10);
end
