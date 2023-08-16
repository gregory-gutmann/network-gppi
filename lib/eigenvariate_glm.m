%% Get SPM.mat for eigenvariate.nii
% Gregory Gutmann (30.11.2022)

function eigenvariate_glm(ntwFolder, evGLM)

% Set-up
evGLM.folder      = {[ntwFolder, 'eigenvariates\']};
evGLM.spmmat      = strcat(evGLM.folder, 'SPM.mat');
for sess=1:evGLM.sess
    evGLM.prepro(sess) = {[ntwFolder, 'eigenvariates\eigenvariates_sess_', num2str(sess), '.nii']};
end

% Specifiy fmri subject model
matlabbatch{1}.spm.stats.fmri_spec.dir = evGLM.folder;
matlabbatch{1}.spm.stats.fmri_spec.timing.units = evGLM.tunits;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = evGLM.RT;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 1    
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;  
for sess=1:evGLM.sess
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).scans = evGLM.prepro(sess);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi = evGLM.design(sess);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi_reg = evGLM.cofounds(sess);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).hpf = 128;
end 
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

% Run batch
spm_jobman('run', matlabbatch);
clear matlabbatch;



