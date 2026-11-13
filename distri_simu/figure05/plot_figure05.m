function fig = plot_figure05(t,originForce,centripetal,tangential,leverLengthsMm,timeUnit)
%PLOT_FIGURE05 Plot origin force and two lever-arm acceleration cases.
%
% Inputs
%   t - N-element times in s.
%   originForce - N-by-3 body specific force in m/s^2.
%   centripetal - N-by-3-by-2 centripetal acceleration arrays in m/s^2.
%   tangential - N-by-3-by-2 tangential acceleration arrays in m/s^2.
%   leverLengthsMm - Two lever-arm lengths used in the legend, mm.
%   timeUnit - Optional display unit, s or h, default h.
%
% Outputs
%   fig - Three-panel figure handle showing body x components in m/s^2.
%
% Related functions
%   Called by experiment main scripts.
fig = figure('Visible','on','Color','w','Name','Figure 05 specific-force terms', ...
    'Position',[100 80 1000 800]);
layout = tiledlayout(fig,3,1,'TileSpacing','compact','Padding','compact');
titles = {'Specific-force truth: x component (term 1)', ...
    'Centripetal acceleration: x component (term 2)', ...
    'Tangential acceleration: x component (term 3)'};
ax = gobjects(3,1);
if nargin<6, timeUnit='h'; end
switch timeUnit
    case 's', plotTime=t;
    case 'h', plotTime=t/3600;
    otherwise, error('plot_figure05:TimeUnit','The time unit must be s or h.');
end
leverNames = {sprintf('%g mm',leverLengthsMm(1)),sprintf('%g mm',leverLengthsMm(2))};
for row=1:3
    ax(row) = nexttile(layout,row);
    if row==1
        plot(ax(row),plotTime,originForce(:,1),'LineWidth',1.5,'Color',[0 0.4470 0.7410]);
    else
        if row==2
            values = centripetal(:,1,:);
        else
            values = tangential(:,1,:);
        end
        plot(ax(row),plotTime,values(:,1,1),'-','Color',[0 0.4470 0.7410],'LineWidth',1.5);
        hold(ax(row),'on');
        plot(ax(row),plotTime,values(:,1,2),'--','Color',[0.8500 0.3250 0.0980],'LineWidth',1.5);
        legend(ax(row),leverNames,'Location','best');
    end
    title(ax(row),titles{row});
    ylabel(ax(row),'x (m/s^2)');
    if row==3, xlabel(ax(row),sprintf('Time (%s)',timeUnit)); end
    grid(ax(row),'on'); box(ax(row),'on');
    set(ax(row),'FontName','Times New Roman','FontSize',10);
    xlim(ax(row),[plotTime(1),plotTime(end)]);
end
linkaxes(ax,'x');
end
