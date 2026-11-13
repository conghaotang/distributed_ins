%FIGURE08_MAIN Plot three specific-force reconstruction errors after running figure07_main.
figureDir=fileparts(mfilename('fullpath'));
rootDir=fileparts(fileparts(figureDir));
addpath(genpath(rootDir));
sourceResult=fullfile(fileparts(figureDir),'figure07','figure07_reconstruction_result.mat');
loaded=load(sourceResult,'reconstructionResult','configuration');
reconstructionResult=loaded.reconstructionResult;
% The true-parameter correction case includes measurement noise.
reports=cell(1,reconstructionResult.systemCount);
fig=gobjects(1,reconstructionResult.systemCount);
for systemIndex=1:reconstructionResult.systemCount
    displayResult=reconstructionResult.system(systemIndex);
    displayResult.caseNames={'TrueParametersError','SmallResidualError','LargeResidualError'};
    excelFile=fullfile(figureDir,sprintf('figure08_specific_force_system%d.xlsx',displayResult.id));
    comparisonTable=export_cases(displayResult,'force_error',excelFile);
    % Order columns by axis, with time followed by the three X, Y, and Z cases.
    comparisonTable=comparisonTable(:,[1,2,5,8,3,6,9,4,7,10]);
    writetable(comparisonTable,excelFile,'Sheet','Comparison','WriteMode','replacefile');
    fig(systemIndex)=plot_cases(displayResult,'force_error',8);
    set(fig(systemIndex),'Name',sprintf('Figure 08 System %d',displayResult.id));
    set(findall(fig(systemIndex),'Type','line','DisplayName','Exact calibration'), ...
        'DisplayName','True-parameter correction');
    set(findall(fig(systemIndex),'Type','legend'),'Location','northeast');
    reports{systemIndex}=struct('figure',8,'systemId',displayResult.id, ...
        'excelFile',excelFile,'sourceResult',sourceResult, ...
        'sampleCount',reconstructionResult.sampleCount,'rms',displayResult.forceRms);
end
report=[reports{:}];
