%% Tutorial for gPPI-network anaylsis based on one subjects
% Gregory Gutman (11.08.22)

%{
%% Usage
For this tutorial to run you only need to update this working directory .
Besides the visualization, all processes are coordinated within this
script, but for more information about the arguments see inits.m. The data 
folder contains the different input data sets and the gppi-network folder 
contains the output.
As the function iterate through a lot of regions, some might need a moment.
As a prerequisite you need SPM and some SPM-functions might rely on the 
Image Processing Toolbox.


%% About 
In this tutorial I used fMRI data from one subject provided by Masterdon 
et al. (2016). During their experiment they compared the effect of 
showing high- and low-calorie food as well as controll images early and 
late in the day. For the tutorial I only analysed the morning session. 
Given the three conditions 'high', 'low' and 'cont' (for control) the 
following regressors where used in modelling the respected target time series:

target(t) = β0 + β11 high(t) + β12 low(t) + β13 cont(t) + β2 seed(t) + ...
    β31 high_seed(t) + β32 low_seed(t) + β33 cont_seed(t) + e(t)

The used network consists of all 246 regions included in the Brainnetome Atlas 
developed by Fan et al. (2016) which I already realigned to fit the dimension 
and orientation of the bold data. 
In this script, individual ROI-masks with a sphere of 8 mm radius are created. 
There going to be centered around peaks based on standard 
first-level activity contrasts, in this case high>low calorie food images. 
The different gPPI parameters are then created for each seed region and 
in a following step applied to each target region to estimate the beta 
weights. Similar to first-level activity-analysis the beta weights can 
be combined to look at contrasts of interest, which is done in the last
script.

%}    

%% Working directory (needs to be updated)
wkdir           =  '/Users/gregory/Arbeit/gppi-network/';
% Adds file separator if necessary
if wkdir(end) ~= filesep
    wkdir           = [wkdir,filesep];
end

%% Add paths to library and inits.m
addpath([wkdir, 'lib'])
addpath([wkdir, 'tutorial'])


%% Download nii.gz files (to large for regular download over github)
% If it doesn't work you can increase the time out further using the weboptions-
% function. Or you download the data directly from github and put them in 
% the folder '.../tutorial/data/preprocessed'
disp('Downloading nii.gz-files. Might take a little bit.')
preprocFolder = [wkdir,'tutorial',filesep,'data',filesep,'preprocessed',filesep];
optionTimeout = weboptions('Timeout', 30);
websave([preprocFolder,'sub-1304am_preproc1.nii.gz'], ...
    ['https://github.com/gregory-gutmann/gppi-network/raw/main/tutorial/data/' ...
    'preprocessed/sub-1304am_preproc1.nii.gz?download='], ...
    optionTimeout);
websave([preprocFolder,'sub-1304am_preproc2.nii.gz'], ...
    ['https://github.com/gregory-gutmann/gppi-network/raw/main/tutorial/data/' ...
    'preprocessed/sub-1304am_preproc2.nii.gz?download='], ...
    optionTimeout);


%% Initialize parameters
% Saves worksapce of inits-function and loads them into main.m
% Inits function also unpacks preprocessed data set and
% conducts necessary first-level analysis
inits(wkdir)
load([wkdir,'tutorial',filesep,'parameters.mat'])


%% Create gPPI beta weights
% Adapts general roi-masks to individual mask by drawing a volumne around defined peaks
roi_peak_masks(fstFolder,ntwFolder,roiFolder,roiList,sphere,sphereInfo,contPeak,directionList);

% Extract eigenvariates
%   creates seed-eigenvariate: whitened, filtered, cofounds removed 
%   creates target-eigenvariate: whitened, frequenz-filtered
eigenvariate(fstFolder,ntwFolder,contAdj,roiList,roiSubFolder);

% Binds multiple eigenvariate.mat's into a single nifti
eigenvariate2nii(fstFolder,ntwFolder);

% Creates SPM.mat for eigenvariate.nii containing all relevant information 
% e.g. design structure
eigenvariate_glm(ntwFolder, evGLM);

% creates gppi parameters for all eigenvariates including ...
%   design variables
%   deconvoluded seed timeseries
%   interaction between design variables and seed time series
gppi_parameter(fstFolder, ntwFolder, tasks);

% Apply gppi parameters on target rois to get beta values for each individual
errorRoisBeta   = gppi_beta(ntwFolder, roiList);


%% Run gPPI-contrasts
% Computes t- and F-contrasts based on beta values for each individual

% Define contrast for physiological parameter
contrasts(1).name       = 'roi_ev';
contrasts(1).stat       = 'T';
contrasts(1).c          = [zeros(6,1); 1; zeros(12,1); 1; zeros(8,1)];

% Define contrast for high- over low-calorie-food for psychological parameter
contrasts(2).name       = 'hi_over_low';
contrasts(2).stat       = 'T';
contrasts(2).c          = [1; -1; zeros(11,1); 1; -1; zeros(13,1)];

% Define contrast for high- over low-calorie food for psychophysiological-interaction parameter
contrasts(3).name       = 'ppi-hi_over_low';
contrasts(3).stat       = 'T';
contrasts(3).c          = [zeros(3,1); 1; -1; zeros(11,1); 1; -1; zeros(10,1)];

% Run contrasts
errorRoisCont           = gppi_contrasts(ntwFolder,roiList,contrasts);

% Bind estimates for different rois into single matrix
% bind roi estimates of spm t- or F-values into single nifti
roi_ev          = bind_gppi_contrasts(ntwFolder, 'spmT_0001');
hi_over_low     = bind_gppi_contrasts(ntwFolder, 'spmT_0002');
ppi_hi_over_low = bind_gppi_contrasts(ntwFolder, 'spmT_0003');

% Save gPPI-matrizes
save([wkdir,'tutorial',filesep,'gppi-matrizes.mat'],'roi_ev','hi_over_low','ppi_hi_over_low')
heatmap(ppi_hi_over_low)








