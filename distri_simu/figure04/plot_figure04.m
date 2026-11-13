function fig = plot_figure04(t,gyroObservation)
%PLOT_FIGURE04 Plot four single-axis gyro observation channels.
%
% Inputs
%   t - N-element observation times in s.
%   gyroObservation - N-by-4 gyro observations in rad/s.
%
% Outputs
%   fig - Four-panel figure handle with time in h and observations in deg/s.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible','on','Color','w','Name','Figure 04 gyro observations', ...
    'Position',[100 100 1000 800]);
sensorNames = {'A','B','C','D'};
ax = gobjects(4,1);
for sensorIndex = 1:4
    ax(sensorIndex) = subplot(4,1,sensorIndex,'Parent',fig);
    plot(ax(sensorIndex),t/3600,rad2deg(gyroObservation(:,sensorIndex)), ...
        'LineWidth',1.5,'Color',[0 0.4470 0.7410]);
    title(ax(sensorIndex),['Gyro ',sensorNames{sensorIndex}]);
    ylabel(ax(sensorIndex),['\omega_',sensorNames{sensorIndex},' (°/s)']);
    grid(ax(sensorIndex),'on');
    box(ax(sensorIndex),'on');
    set(ax(sensorIndex),'FontName','Times New Roman','FontSize',10);
    xlim(ax(sensorIndex),[t(1),t(end)]/3600);
end
xlabel(ax(4),'Time (h)');
linkaxes(ax,'x');
end
