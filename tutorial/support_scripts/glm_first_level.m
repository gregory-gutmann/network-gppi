%% Compute activity first-level analysis for subject using SPM
% Gregory Gutman (11.08.22)

%{
This scripts decompresses nifti data and runs a activity first-level analysis
(Both to large to be downloaded via GitHub).
%}

function glm_fstlevel(wkdir)

%% Set up subject-specific parameters
% Participant
sub             = 'sub-1304am';

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
evGLM.hpf        = 180;

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
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 20; 
matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = evGLM.prepro(1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = evGLM.design(1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = evGLM.cofounds(1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = evGLM.hpf;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = evGLM.prepro(2);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = evGLM.design(2);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = evGLM.cofounds(2);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = evGLM.hpf;
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
