function T = export_cases(result,quantity,excelFile)
%EXPORT_CASES Build or write a table of one system's calibration cases.
%
% Inputs
%   result - System result containing t, caseNames, and quantity-specific truth/estimate or
%       error arrays.
%   quantity - gyro, gyro_error, force, force_error, attitude, attitude_arcsec, velocity, or
%       position.
%   excelFile - Optional workbook path. Supplying it writes the Comparison sheet.
%
% Outputs
%   T - Table with Time_s and labeled case/component columns. Position uses m, velocity m/s, and
%       angles follow quantity.
%
% Related functions
%   Called by experiment main scripts.
switch quantity
    case 'gyro'
        truth=result.wTruth; estimates=result.wEstimate;
        components={'X','Y','Z'}; unit='rad_s';
    case 'gyro_error'
        truth=[];
        estimates=rad2deg(result.wEstimate-result.wTruth)*3600;
        components={'X','Y','Z'}; unit='deg_h';
    case 'force'
        truth=result.fTruth; estimates=result.fEstimate;
        components={'X','Y','Z'}; unit='m_s2';
    case 'force_error'
        truth=[]; estimates=result.fEstimate-result.fTruth;
        components={'X','Y','Z'}; unit='m_s2';
    case 'attitude'
        truth=[]; estimates=rad2deg(result.attitudeError);
        components={'PhiE','PhiN','PhiU'}; unit='deg';
    case 'attitude_arcsec'
        truth=[]; estimates=rad2deg(result.attitudeError)*3600;
        components={'PhiE','PhiN','PhiU'}; unit='arcsec';
    case 'velocity'
        truth=[]; estimates=result.velocityError;
        components={'E','N','U'}; unit='m_s';
    case 'position'
        truth=[]; estimates=result.positionError(:,[2 1 3],:);
        unit='m';
        components={'Latitude','Longitude','Height'};
end
values=result.t; names={'Time_s'};
if ~isempty(truth)
    values=[values,truth];
    for j=1:3, names{end+1}=['Truth',components{j},'_',unit]; end
end
for c=1:numel(result.caseNames)
    values=[values,estimates(:,:,c)]; %#ok<AGROW>
    for j=1:3, names{end+1}=[result.caseNames{c},components{j},'_',unit]; end
end
T=array2table(values,'VariableNames',names);
if nargin==3
    writetable(T,excelFile,'Sheet','Comparison','WriteMode','replacefile');
end
end
