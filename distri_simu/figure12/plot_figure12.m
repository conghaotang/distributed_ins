function fig = plot_figure12(avp, attRaw, attUnwrapped)
%PLOT_FIGURE12 Plot raw and unwrapped attitude sequences.
%
% Inputs
%   avp - N-by-7 source trajectory with time in s.
%   attRaw - N-by-3 raw [theta phi psi] angles in rad.
%   attUnwrapped - N-by-3 unwrapped angles in rad.
%
% Outputs
%   fig - Three-component figure handle with time in s and angles in deg.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible', 'on', 'Color', 'w', 'Name', 'Figure 12 attitude');
labels = {'Pitch (°)','Roll (°)','Heading (°)'};
for k = 1:3
    ax = subplot(3,1,k, 'Parent', fig);
    plot(ax, avp(:,7), rad2deg(attRaw(:,k)), '.', 'DisplayName', 'raw'); hold(ax, 'on');
    plot(ax, avp(:,7), rad2deg(attUnwrapped(:,k)), '-', 'DisplayName', 'unwrapped');
    grid(ax, 'on'); ylabel(ax, labels{k});
    if k == 1, title(ax, 'Figure 12: raw and unwrapped attitude'); end
    if k == 3, xlabel(ax, 'Time / s'); end
    legend(ax, 'Location', 'best');
end
end
