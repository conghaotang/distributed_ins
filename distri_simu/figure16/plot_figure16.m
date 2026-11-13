function fig=plot_figure16(result)
%PLOT_FIGURE16 Plot subsystem positions and local-frame attitude differences.
%
% Inputs
%   result - sourceTime/queryTime in s and system entries with sourcePosition/position [rad rad
%       m] and sourceAttitude/attitude [theta phi psi] in rad.
%
% Outputs
%   fig - Two figure handles for position and attitude, with angles in deg and relative attitude
%       differences in arcsec.
%
% Related functions
%   Called by experiment main scripts.
systemCount=numel(result.system);
colors=lines(systemCount);
fig=gobjects(1,2);
angleSymbols={'\theta','\phi','\psi'};
for quantity=1:2
    if quantity==1
        caption='Figure 16 system positions';
        sourceField='sourcePosition'; queryField='position';
        labels={'Latitude (deg)','Longitude (deg)','Height (m)'};
        factors=[180/pi,180/pi,1];
    else
        caption='Figure 16 local-frame attitudes and differences';
        sourceField='sourceAttitude'; queryField='attitude';
        labels={'\theta (deg)','\phi (deg)','\psi (deg)'};
        factors=[180/pi,180/pi,180/pi];
    end
    fig(quantity)=figure('Color','w','Visible','on','Name',caption, ...
        'Position',[100 80 1000+200*(quantity-1) 800]);
    layout=tiledlayout(fig(quantity),3,quantity,'TileSpacing','compact','Padding','compact');
    ax=gobjects(3*quantity,1);
    for j=1:3
        index=quantity*(j-1)+1;
        ax(index)=nexttile(layout,index);
        hold(ax(index),'on');
        for s=1:systemCount
            plot(ax(index),result.queryTime,result.system(s).(queryField)(:,j)*factors(j), ...
                '-','Color',colors(s,:),'LineWidth',1.5, ...
                'DisplayName',sprintf('System %d interpolation',result.system(s).id));
            plot(ax(index),result.sourceTime,result.system(s).(sourceField)(:,j)*factors(j), ...
                'o','Color',colors(s,:),'MarkerSize',4,'LineWidth',1, ...
                'DisplayName',sprintf('System %d original nodes',result.system(s).id));
        end
        ylabel(ax(index),labels{j});
        if j==1
            legend(ax(index),'Location','best','NumColumns',2);
            if quantity==2, title(ax(index),'Attitude in each local navigation frame'); end
        end
        if j==3, xlabel(ax(index),'Time (s)'); end
        if quantity==2
            ax(index+1)=nexttile(layout,index+1);
            hold(ax(index+1),'on');
            for s=1:systemCount
                delta=result.system(s).attitude(:,j)-result.system(1).attitude(:,j);
                delta=atan2(sin(delta),cos(delta))*180/pi*3600;
                sourceDelta=result.system(s).sourceAttitude(:,j)-result.system(1).sourceAttitude(:,j);
                sourceDelta=atan2(sin(sourceDelta),cos(sourceDelta))*180/pi*3600;
                plot(ax(index+1),result.queryTime,delta,'-','Color',colors(s,:),'LineWidth',1.5, ...
                    'DisplayName',sprintf('System %d - System %d', ...
                    result.system(s).id,result.system(1).id));
                plot(ax(index+1),result.sourceTime,sourceDelta,'o','Color',colors(s,:), ...
                    'MarkerSize',4,'LineWidth',1,'HandleVisibility','off');
            end
            ylabel(ax(index+1),['\Delta ',angleSymbols{j},' (arcsec)']);
            if j==1
                title(ax(index+1),'Local-frame angle difference');
                legend(ax(index+1),'Location','best');
            end
            if j==3, xlabel(ax(index+1),'Time (s)'); end
        end
    end
    for k=1:numel(ax)
        xlim(ax(k),result.queryTime([1 end]));
        grid(ax(k),'on'); box(ax(k),'on');
        set(ax(k),'FontName','Times New Roman','FontSize',10);
    end
    linkaxes(ax,'x');
end
end
