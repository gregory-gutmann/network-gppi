%% Get SPM.mat for eigenvariate.nii
% Gregory Gutmann (30.11.2022)

function eigenvariate_glm(fstFolder,ntwFolder)

% Set-up
load([fstFolder 'SPM.mat']);
glmSPM          = SPM;
outputFolder    = {[ntwFolder,'eigenvariates',filesep]};
for sess=1:length(glmSPM.Sess)
    prepro(sess)    = {[ntwFolder,'eigenvariates',filesep,'eigenvariates_sess_',num2str(sess),'.nii']};
end

% Save design covariates and cofound regressors based on glmSPM structure
for sess=1:length(glmSPM.Sess)
    % Save designmatrices
    names           = horzcat(glmSPM.Sess(sess).U.name);
    onsets          = {glmSPM.Sess(sess).U.ons};
    durations       = {glmSPM.Sess(sess).U.dur};
    design(sess)    = {[outputFolder{1} 'design_sess-' num2str(sess) '.mat']};
    save(design{sess},'onsets','names','durations');
    
    % Save cofounds
    R               = glmSPM.Sess(sess).C.C;
    cofounds(sess)  = {[outputFolder{1} 'cofounds_sess-' num2str(sess) '.mat']};
    save(cofounds{sess},'R');
end 

% Specifiy fmri subject model
matlabbatch{1}.spm.stats.fmri_spec.dir = outputFolder;
matlabbatch{1}.spm.stats.fmri_spec.timing.units = glmSPM.xBF.UNITS;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = glmSPM.xY.RT;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 1    
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;  
for sess=1:length(glmSPM.Sess)
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).scans = prepro(sess);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi = design(sess);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).multi_reg = cofounds(sess);
    matlabbatch{1}.spm.stats.fmri_spec.sess(sess).hpf = glmSPM.xX.K(sess).HParam;
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

% Delete created design covariates and cofound regressors 
for sess=1:length(glmSPM.Sess)
    delete(design{sess});
    delete(cofounds{sess});
end 

