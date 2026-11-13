function run_experiment(script,duration_s)
%RUN_EXPERIMENT Run one experiment and close the figure windows it creates.
%
% Inputs
%   script - Full path to an experiment main script.
%   duration_s - Explicit duration override in s.
%
% Outputs
%   None.
%
% Related functions
%   Called by run_all_experiments.
experimentDuration_s=duration_s; %#ok<NASGU>
previousFigures=findall(groot,'Type','figure');
run(script);
createdFigures=setdiff(findall(groot,'Type','figure'),previousFigures);
close(createdFigures);
end
