function fig = plot_cases(result,quantity,figureNumber)
%PLOT_CASES Plot one system's reconstructed quantities or navigation errors.
%
% Inputs
%   result - System result with t, caseNames, residualFractions, and quantity-specific arrays.
%   quantity - gyro/gyro_error, force/force_error, attitude/attitude_arcsec, velocity, position,
%       euler, or geodetic.
%   figureNumber - Scalar identifier used in the figure name.
%
% Outputs
%   fig - Figure handle. Time uses s, position errors m, and angular units follow quantity.
%
% Related functions
%   Called by experiment main scripts.
switch quantity
    case 'gyro'
        truth=result.wTruth; estimates=result.wEstimate;
        unit='rad/s'; components={'x','y','z'}; caption='Angular velocity';
    case 'gyro_error'
        truth=[];
        estimates=rad2deg(result.wEstimate-result.wTruth)*3600;
        unit='deg/h'; components={'x','y','z'};
        caption='Angular velocity reconstruction error';
    case 'force'
        truth=result.fTruth; estimates=result.fEstimate;
        unit='m/s^2'; components={'x','y','z'}; caption='Specific force';
    case 'force_error'
        truth=[]; estimates=result.fEstimate-result.fTruth;
        unit='m/s^2'; components={'x','y','z'};
        caption='Specific force reconstruction error';
    case 'attitude'
        truth=[]; estimates=rad2deg(result.attitudeError);
        unit='°'; components={'\phi_E','\phi_N','\phi_U'}; caption='Attitude misalignment error';
    case 'attitude_arcsec'
        truth=[]; estimates=rad2deg(result.attitudeError)*3600;
        unit='arcsec'; components={'\phi_E','\phi_N','\phi_U'}; caption='Attitude misalignment error';
    case 'euler'
        truth=[]; estimates=rad2deg(result.eulerError);
        unit='°'; components={'Heading','Pitch','Roll'}; caption='Attitude error';
    case 'geodetic'
        truth=[]; estimates=result.geodeticPositionError;
        estimates(:,1:2,:)=rad2deg(estimates(:,1:2,:));
        unit={'°','°','m'}; components={'Latitude','Longitude','Height'};
        caption='Position error';
    case 'velocity'
        truth=[]; estimates=result.velocityError;
        unit='m/s'; components={'V_E','V_N','V_U'}; caption='Velocity error';
    case 'position'
        truth=[]; estimates=result.positionError(:,[2 1 3],:);
        unit='m';
        components={'Latitude','Longitude','Height'}; caption='Position error';
end
if ischar(unit), unit=repmat({unit},1,3); end
plotTime=result.t; timeUnit='s';
fig=figure('Color','w','Visible','on','Name',sprintf('Figure %02d %s',figureNumber,caption), ...
    'Position',[100 80 1000 800]);
layout=tiledlayout(fig,3,1,'TileSpacing','compact','Padding','compact');
colors=[0 .447 .741;.85 .325 .098;.494 .184 .556];
styles={'-','-','-'};
ax=gobjects(3,1);
for j=1:3
    ax(j)=nexttile(layout,j);
    hold(ax(j),'on');
    if ~isempty(truth)
        plot(ax(j),plotTime,truth(:,j),'k-','LineWidth',1.5,'DisplayName','Truth');
    end
    for c=1:numel(result.caseNames)
        if result.residualFractions(c)==0
            name='Exact calibration';
        else
            name=sprintf('%g%% residual',100*result.residualFractions(c));
        end
        plot(ax(j),plotTime,estimates(:,j,c),'Color',colors(c,:), ...
            'LineStyle',styles{c},'LineWidth',1.5,'DisplayName',name);
    end
    ylabel(ax(j),sprintf('%s (%s)',components{j},unit{j}));
    if j==1, title(ax(j),caption); legend(ax(j),'Location','best'); end
    if j==3, xlabel(ax(j),sprintf('Time (%s)',timeUnit)); end
    grid(ax(j),'on'); box(ax(j),'on');
    set(ax(j),'FontName','Times New Roman','FontSize',10);
    xlim(ax(j),plotTime([1 end]));
end
linkaxes(ax,'x');
end
