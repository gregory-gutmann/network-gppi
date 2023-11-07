%% Bind gppi contrasts of single subject of spm t- or F-values into single nifti
% Gregory Gutmann (01.12.2022)

function conBindMat = bind_gppi_contrasts (ntwFolder,spm_contrast)

% Set-up
estFolder       = [ntwFolder,'gppi',filesep,'estimates',filesep];
estList         = dir([estFolder,'**',filesep,spm_contrast, '.nii']);
estList         = {estList.folder};

% Get contrast estimates and bind in matrix
conBindMat      = [];
for i=1:length(estList)
    conFile         = [estList{i},filesep,spm_contrast,'.nii'];
    conData         = spm_data_read(conFile);
    conBindMat      = [conBindMat; conData'];
end

% Save matrix
save([estFolder, 'gppi_mat_', spm_contrast],'conBindMat') 
