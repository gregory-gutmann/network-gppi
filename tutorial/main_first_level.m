%% Tutorial for gPPI-network anaylsis based on one subjects
% Gregory Gutman (04.01.23)

%{
%% Usage
This tutorial explaines how to use the gppi-network toolbox to compute 
the first-level whole-brain connectivity for one example subject (based on 
open access data), which can very easily be extended to multiple subjects. 

For this part to work, you need to set up a structure containing all 
relevant parameters. An explaination of the needed parameters is given at 
the end of this commentary. 

The second part gives an examplary analysis route for a possible second-
level analysis using simulated data which are based on data acquired 
during a emotion regulation study in depressed patients.

For this tutorial to run you only need to update this working directory .
As a prerequisite you need SPM and due to some internal SPM functions 
the Image Processing Toolbox. Before you can run the connectivity analysis, 
you also have to compute conventional activity analysis using SPM, which are 
implemented in this script.

To shorten the runtime, I changed the number of included ROIs to 20. 
If you want to run the tutorial for the whole brain, just change or remove 
the marked line. My computer needed around 12 minutes to compute all connections. 

Within the folder support_script you can also find the script
'visualization_gppi_mat.m' with which I visualised the resulting data.


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

%% Parameters for gppi-network structure
Generell parameters
---------------------------------------------------------------------------
roiFolder       - Folder containing ROI masks. Masks need to bee realigned 
    to fit the dimension and orientation of the volumne task.
roiList         - List of ROIs
glmFolder       - Folder containing first-level activity analysis
ngppiFolder     - Folder to contain gppi-network results (output)
subjectList     - List of subject codes
    Subject code needs to match folder names for first-level activity
    analysis. Contains in this case only one subject. However, gppi-network 
    will be computed for all subjects in this list. Should you want to 
    include more subjects it has to be e.g., {'sub-1' 'sub-2' 'sub-3').
conds           - Conditions which should be included in the gPPI model. 
    Need to be named like in the activity first-level analysis.
contAdj         - Contrast on which basis eigenvariate is adjusted 
    Side note: Adjustment for regressors which are not part of contrast
    Here contrast is effects of interest, so adjustment for all other
    regressors (6 rigid body regressors).


---------------------------------------------------------------------------
Contrast parameters 
---------------------------------------------------------------------------
Computes n-contrasts based on beta values (similar to SPM)
contrasts(n).name   - Contrast name
contrasts(n).stat   - Contrast type ('T' or 'F')
contrasts(n).c      - Combination of regressors to compute contrast


---------------------------------------------------------------------------
Optional parameters
---------------------------------------------------------------------------
A sphere will be drawn around peak voxel for each individual. If instead 
whole ROI should be used, just don't define these parameters. In this case 
I used a 8mm-redius-sphere, but any other size or volumne type can be used.

sphere      - Sphere mask. 
sphereInfo  - Leads to zero-nifti (with equal proportions to bold sequence)
    onto which spheres are drawn. I create these by just taking one of
    the contrast in the first-level folder and multiplying it by 0. 
contPeak    - Contrasts on which basis the peak voxel should be choosen. 
    Here I took the fourth contrast, which is high-calorie food images over
    low-calorie food images.
direktionList - Direction list: defines if maximum peak (1) or minimum peak 
    (0) should be used respectivly for each region as the center of a
    sphere.Here only positive peaks are used meaning high>low-calorie food for
    every region. With 0 the reversed contrast - in this case low>high-calorie 
    food - would be used for peak selection for choosen regions

%}    


%==========================================================================
%% Preparations
%==========================================================================
%% Working directory (needs to be updated)
% Change wd to folder that contains lib- and tutorial-folder
wkdir           =  'C:\Users\grego\Desktop\network-gppi-main\';
% Adds file separator if necessary
if wkdir(end) ~= filesep
    wkdir           = [wkdir,filesep];
end

%% Add paths to library and inits.m
addpath([wkdir, 'lib'])
addpath([wkdir, 'tutorial/support_scripts'])


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

%% Decompresses nifti data and run an activity first-level analysis
glm_first_level(wkdir);


%==========================================================================
%% Compute gppi-network for one subject
%==========================================================================
%% Generell parameters
N.roiFolder         = [wkdir,'tutorial',filesep,'roi_masks',filesep];
N.roiList           = {dir([N.roiFolder,'*.nii']).name};
N.roiList           = N.roiList(1:20);  % Remove or change line if you want to 
                            % include all or a different set of connections
N.glmFolder         = [wkdir,'tutorial',filesep,'data',filesep,'firstlevel',filesep];
N.ngppiFolder       = [wkdir,'tutorial',filesep,'gppi-network',filesep];
N.subjectList       = {'sub-1304am'};    % Can include multiple subjects!
N.tasks             = {'hi'  'low'  'cont'};
N.contAdj           = 6;

%% Contrast parameters
% Contrast for physiological parameter
N.contrasts(1).name     = 'roi_ev';             
N.contrasts(1).stat     = 'T';
N.contrasts(1).c        = [zeros(6,1); 1; zeros(12,1); 1; zeros(8,1)];
% Contrast for high- over low-calorie-food for psychological parameter
N.contrasts(2).name     = 'hi_over_low';
N.contrasts(2).stat     = 'T';
N.contrasts(2).c        = [1; -1; zeros(11,1); 1; -1; zeros(13,1)];
% Contrast for high- over low-calorie food for psychophysiological-interaction parameter
N.contrasts(3).name     = 'ppi-hi_over_low';
N.contrasts(3).stat     = 'T';
N.contrasts(3).c        = [zeros(3,1); 1; -1; zeros(11,1); 1; -1; zeros(10,1)];

%% Optional parameters
N.sphere            = load([wkdir,'tutorial',filesep,'templates',filesep,'sphere_8mm.mat']).sphereCutXYZ;
N.sphereInfo        = spm_vol([wkdir,'tutorial',filesep,'templates',filesep,'sphereInfo.nii']);
N.contPeak          = 'spmT_0004.nii';      
N.directionList     = ones(1,length(N.roiList));

%% Compute gppi-network
tic
ngppi(N);
toc


