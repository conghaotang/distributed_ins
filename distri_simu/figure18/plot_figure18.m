function fig=plot_figure18(result)
%PLOT_FIGURE18 Plot origin x force and internal lever-arm acceleration terms.
%
% Inputs
%   result - t in s and system entries with id, originForceX, tangentialX, and centripetalX,
%       each N-by-1 in m/s^2.
%
% Outputs
%   fig - Single-axes figure handle with three curves per system.
%
% Related functions
%   Called by experiment main scripts.
fig=figure('Color','w','Visible','on','Name','Figure 18 x-axis force and lever-arm acceleration', ...
    'Position',[100 100 1000 450]);
ax=axes(fig);
hold(ax,'on');
colors=lines(numel(result.system));
for s=1:numel(result.system)
    plot(ax,result.t,result.system(s).originForceX,'-','Color',colors(s,:), ...
        'LineWidth',1.5,'DisplayName',sprintf('System %d origin',result.system(s).id));
    plot(ax,result.t,result.system(s).tangentialX,'--','Color',colors(s,:), ...
        'LineWidth',1.5,'DisplayName',sprintf('System %d tangential',result.system(s).id));
    plot(ax,result.t,result.system(s).centripetalX,':','Color',colors(s,:), ...
        'LineWidth',1.5,'DisplayName',sprintf('System %d centripetal',result.system(s).id));
end
xlabel(ax,'Time (s)');
ylabel(ax,'x component (m/s^2)');
legend(ax,'Location','best','NumColumns',2);
set(ax,'FontName','Times New Roman','FontSize',10);
grid(ax,'on'); box(ax,'on');
xlim(ax,result.t([1 end]));
end
