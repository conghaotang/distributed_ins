function summary=run_all_experiments(duration_s,figures)
%RUN_ALL_EXPERIMENTS Execute selected experiment scripts and collect elapsed times.
%
% Inputs
%   duration_s - Input duration in s, or Inf for the complete trajectory.
%   figures - Optional experiment identifiers, default [0:9 12:20].
%
% Outputs
%   summary - Table with Figure and Elapsed_s. Results are saved in each experiment folder.
%
% Related functions
%   Calls run_experiment.
simuDir=fileparts(fileparts(mfilename('fullpath')));
if nargin<2
    figures=[0:9,12:20];
end
summary=table(figures.',zeros(numel(figures),1),'VariableNames',{'Figure','Elapsed_s'});
for j=1:numel(figures)
    script=fullfile(simuDir,sprintf('figure%02d',figures(j)),sprintf('figure%02d_main.m',figures(j)));
    start=tic;
    run_experiment(script,duration_s);
    summary.Elapsed_s(j)=toc(start);
    fprintf('Figure %02d completed in %.2f s\n',figures(j),summary.Elapsed_s(j));
end
end
