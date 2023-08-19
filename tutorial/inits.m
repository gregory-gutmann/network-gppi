%% Set-up script for gPPI-network-tutorial
% Gregory Gutman (11.08.22)

%{
In this function all need parameters are initialized and shortly explained.
It runs in the main-script and needs the adapted workind directory as an
input. The nifti files are also decompressed and first-level activity analysis
are conducted.

Overview of subject-unspecific parameters
- roiFolder
- roiList
- sphere
- sphereInfo
- contPeak
- direktionList
- contAdj
- tasks

Overview of subject-specific parameters
- sub
- fstFolder
- ntwFoler
- roiSubFolder
- evGLM
%}

function inits(wkdir)

%% Set up subject-unspecific parameters
% Folder with region mask & list of regions. The region maps are already
% realigned to fit the dimension and orientation of the task.
roiFolder      = [wkdir,'tutorial',filesep,'roi-masks',filesep];
roiList        = dir([roiFolder,'*.nii']);
roiList        = {roiList.name};

% Sphere mask and sphere meta info
    % Sphere will be drawn around peak voxel (see below)
    % In this case I used a 8mm-redius-sphere, any other size or volumne
    % type can be used
    % SphereInfo leads to zero-nifti (with equal proportions to bold sequence)
    % onto which spheres are drawn. I create these by just taking one of
    % the contrast in the first-level folder and multiplying it by 0.
sphere          = load([wkdir,'tutorial',filesep,'templates',filesep,'sphere_8mm.mat']).sphereCutXYZ;
sphereInfo      = spm_vol([wkdir,'tutorial',filesep,'templates',filesep,'sphereInfo.nii']);

% Contrasts on which basis the peak voxel should be choosen
    % Here I took the fourth contrast, which is high-calorie food images
    % over low-calorie food images
contPeak        = 'spmT_0004.nii';

% Direction list: defines if maximum peak (1) or minimum peak (0) should be
% used respectivly for each region as the center of a sphere
    % Here only positive peaks are used meaning high>low-calorie food for
    % every region
    % With 0 the reversed contrast - in this case low>high-calorie food - 
    % will be used for peak selection for choosen regions
directionList   = ones(1,246);

% Contrast on which basis eigenvariate is adjusted 
    % Side note: Adjustment for regressors which are not part of contrast
    % Here contrast is effects of interest, so adjustment for all other
    % regressors (6 rigid body regressors)
contAdj         = 6;

% Task names for which to create gPPI-Parameters
tasks          = {'1'  'hi'  'low'  'cont'};

%% Set up subject-specific parameters
% Participant
sub             = 'sub-1304am';

% (Regular) first-level folder (computed prior)
fstFolder       = [wkdir,'tutorial',filesep,'data',filesep,'firstlevel',filesep,sub,filesep];

% Output or network folder
ntwFolder       = [wkdir,'tutorial',filesep,'gppi-network',filesep,sub,filesep];
% Roi-mask folder within network folder
roiSubFolder    = [ntwFolder,'roi_masks',filesep];

% Information and paths to run GLM for eigenvariates and create needed
% SPM.mat
evGLM           = struct();
evGLM.sess      = 2;
evGLM.RT        = 2;
evGLM.tunits    = ['secs'];
evGLM.sub       = sub;
evGLM.folder    = {[wkdir, 'tutorial',filesep,'data',filesep,'firstlevel',filesep,sub,filesep]};
evGLM.spmmat    = {[wkdir, 'tutorial',filesep,'data',filesep,'firstlevel',filesep,sub,filesep,'SPM.mat']};
evGLM.design(1) = {[wkdir,'tutorial',filesep,'data',filesep,'designmatrices',filesep,sub,'_design1.mat']};
evGLM.design(2) = {[wkdir,'tutorial',filesep,'data',filesep,'designmatrices',filesep,sub,'_design2.mat']};
evGLM.cofounds(1)= {[wkdir,'tutorial',filesep,'data',filesep,'cofounds',filesep,sub,'_6rigidbody_confounds1.txt']};
evGLM.cofounds(2)= {[wkdir,'tutorial',filesep,'data',filesep,'cofounds',filesep,sub,'_6rigidbody_confounds2.txt']};
evGLM.prepro(1)= {[wkdir,'tutorial',filesep,'data',filesep,'preprocessed',filesep,sub,'_preproc1.nii']};
evGLM.prepro(2)= {[wkdir,'tutorial',filesep,'data',filesep,'preprocessed',filesep,sub,'_preproc2.nii']};
evGLM.preprogz(1)= {[wkdir,'tutorial',filesep,'data',filesep,'preprocessed',filesep,sub,'_preproc1.nii.gz']};
evGLM.preprogz(2)= {[wkdir,'tutorial',filesep,'data',filesep,'preprocessed',filesep,sub,'_preproc2.nii.gz']};

%% Decompress nii.gz files
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.files = evGLM.preprogz(1);
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.outdir = {''};
matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.keep = true;
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.files = evGLM.preprogz(2);
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.outdir = {''};
matlabbatch{2}.cfg_basicio.file_dir.file_ops.cfg_gunzip_files.keep = true;

spm_jobman('run', matlabbatch);
clear matlabbatch;

%% Run activity first-level analysis
% specifiy fmri subject model
matlabbatch{1}.spm.stats.fmri_spec.dir = evGLM.folder;
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 40;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1; 
matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = evGLM.prepro(1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = evGLM.design(1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = evGLM.cofounds(1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = evGLM.prepro(2);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = evGLM.design(2);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = evGLM.cofounds(2);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

% estimate frmi subject model
matlabbatch{2}.spm.stats.fmri_est.spmmat = evGLM.spmmat; 
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


% define contrasts (noch überarbeiten)
matlabbatch{3}.spm.stats.con.spmmat = evGLM.spmmat;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'hi'; 
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'low';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'cont';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'hi > low';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'low > hi';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [-1 1];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'repl';
matlabbatch{3}.spm.stats.con.consess{6}.fcon.name = 'effects of interest';
matlabbatch{3}.spm.stats.con.consess{6}.fcon.weights = eye(3);
matlabbatch{3}.spm.stats.con.consess{6}.fcon.sessrep = 'repl';
matlabbatch{3}.spm.stats.con.consess{7}.fcon.name = 'effects of interest controll';
matlabbatch{3}.spm.stats.con.consess{7}.fcon.weights = [0 0 1; 1 0 0; 0 1 0];
matlabbatch{3}.spm.stats.con.consess{7}.fcon.sessrep = 'repl';
matlabbatch{3}.spm.stats.con.delete = 0;

spm_jobman('run', matlabbatch);
clear matlabbatch;

%% Save workspace
save([wkdir,'tutorial',filesep,'parameters.mat'])

end