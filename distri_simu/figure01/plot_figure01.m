function fig = plot_figure01(avp, attRawDeg, attUnwrappedDeg)
%PLOT_FIGURE01 Plot raw and unwrapped attitude samples.
%
% Inputs
%   avp - N-by-7 source trajectory with time in s.
%   attRawDeg - N-by-3 raw [theta phi psi] angles in deg.
%   attUnwrappedDeg - N-by-3 unwrapped angles in deg.
%
% Outputs
%   fig - Three-component attitude figure handle with time displayed in h.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible', 'on', 'Color', 'w', 'Name', 'Figure 01 attitude');
labels = {'theta / deg','phi / deg','psi / deg'};
for k = 1:3
    ax = subplot(3,1,k, 'Parent', fig);
    plot(ax, avp(:,7)/3600, attRawDeg(:,k), '.', 'DisplayName', 'raw');
    hold(ax, 'on');
    plot(ax, avp(:,7)/3600, attUnwrappedDeg(:,k), '-', 'DisplayName', 'unwrapped');
    grid(ax, 'on'); ylabel(ax, labels{k});
    if k == 1, title(ax, 'Figure 01: raw and unwrapped attitude'); end
    if k == 3, xlabel(ax, 'Time / h'); end
    legend(ax, 'Location', 'best');
end
end
