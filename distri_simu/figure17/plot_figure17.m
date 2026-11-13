function fig=plot_figure17(result)
%PLOT_FIGURE17 Plot ideal angular rates and origin forces for each system.
%
% Inputs
%   result - t in s and system entries with id, N-by-3 gyroTruth (rad/s), and N-by-3 forceTruth
%       (m/s^2).
%
% Outputs
%   fig - Three-by-two panel figure handle with rates in deg/s and force in m/s^2.
%
% Related functions
%   Called by experiment main scripts.
fig=figure('Color','w','Visible','on','Name','Figure 17 dual-system ideal motion', ...
    'Position',[100 80 1200 800]);
layout=tiledlayout(fig,3,2,'TileSpacing','compact','Padding','compact');
colors=lines(numel(result.system));
styles={'-','--'};
axesNames={'x','y','z'};
for j=1:3
    for q=1:2
        ax=nexttile(layout,2*(j-1)+q);
        hold(ax,'on');
        for s=1:numel(result.system)
            if q==1
                ideal=rad2deg(result.system(s).gyroTruth(:,j));
            else
                ideal=result.system(s).forceTruth(:,j);
            end
            plot(ax,result.t,ideal,'Color',colors(s,:),'LineWidth',1.5, ...
                'LineStyle',styles{s},'DisplayName',sprintf('System %d',result.system(s).id));
        end
        if q==1
            ylabel(ax,['\omega_',axesNames{j},' (deg/s)']);
        else
            ylabel(ax,sprintf('f_%s (m/s^2)',axesNames{j}));
        end
        if j==1
            legend(ax,'Location','best');
            if q==1, title(ax,'Angular velocity'); else, title(ax,'Specific force'); end
        end
        if j==3, xlabel(ax,'Time (s)'); end
        set(ax,'FontName','Times New Roman','FontSize',10);
        grid(ax,'on'); box(ax,'on');
        xlim(ax,result.t([1 end]));
    end
end
end
