function selected = select_system_array(array,system,referencePoint)
%SELECT_SYSTEM_ARRAY Select subsystem calibration and reference-point lever arms.
%
% Inputs
%   array - Complete sensor calibration with total acc.lever offsets in m.
%   system - Subsystem gyroIndex, accIndex, and 3-by-1 origin lever_b in m.
%   referencePoint - common_origin uses total offsets. system_origin subtracts the origin
%       offset.
%
% Outputs
%   selected - Subsystem calibration matching the array_reconstruct input interface.
%
% Related functions
%   Called by reconstruct_systems.
for sensorCell={'gyro','acc'}
    sensor=sensorCell{1};
    j=system.([sensor,'Index']);
    selected.(sensor).axes=array.(sensor).axes(j,:);
    selected.(sensor).scale=array.(sensor).scale(j);
    selected.(sensor).bias=array.(sensor).bias(j);
    selected.(sensor).Q=array.(sensor).Q(j,j);
end
switch referencePoint
    case 'common_origin'
        selected.acc.lever=array.acc.lever(system.accIndex,:);
    case 'system_origin'
        selected.acc.lever=array.acc.lever(system.accIndex,:)-system.lever_b.';
end
end
