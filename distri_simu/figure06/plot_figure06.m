function fig = plot_figure06(t,accObservation)
%PLOT_FIGURE06 Plot four single-axis accelerometer observation channels.
%
% Inputs
%   t - N-element observation times in s.
%   accObservation - N-by-4 accelerometer observations in m/s^2.
%
% Outputs
%   fig - Four-panel figure handle with time in h and force in m/s^2.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible','on','Color','w','Name','Figure 06 accelerometer observations', ...
    'Position',[100 80 1000 800]);
layout = tiledlayout(fig,4,1,'TileSpacing','compact','Padding','compact');
sensorNames = {'A','B','C','D'};
ax = gobjects(4,1);
time_h = t/3600;
for sensorIndex=1:4
    ax(sensorIndex) = nexttile(layout,sensorIndex);
    plot(ax(sensorIndex),time_h,accObservation(:,sensorIndex), ...
        'LineWidth',1.5,'Color',[0 0.4470 0.7410]);
    title(ax(sensorIndex),['Accelerometer ',sensorNames{sensorIndex}]);
    ylabel(ax(sensorIndex),['f_',sensorNames{sensorIndex},' (m/s^2)']);
    grid(ax(sensorIndex),'on'); box(ax(sensorIndex),'on');
    set(ax(sensorIndex),'FontName','Times New Roman','FontSize',10);
    xlim(ax(sensorIndex),[time_h(1),time_h(end)]);
end
xlabel(ax(4),'Time (h)');
linkaxes(ax,'x');
end
