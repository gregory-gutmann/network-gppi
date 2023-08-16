%% Bind multiple eigenvariate.mat's into single nifti
% Gregory Gutmann (29.11.2022)

function V2d = eigenvariate2nii(fstFolder,ntwFolder)

load([fstFolder, 'SPM.mat']);
sessions        = numel(SPM.Sess);

for sess=1:sessions

    % Set-up
    evFolder        = [ntwFolder, 'eigenvariates/'];
    evList          = dir([evFolder, '*sess_', num2str(sess), '.mat']);     
    evList          = {evList.name};
    evNum           = length(evList);
    
    % Get eigenvariates and bind in matrix
    V2d             = [];
    for i=1:length(evList)
        load([evFolder,evList{i}])
        V2d             = [V2d xY.t]; % original [V2d xY.u]
    end
    
    % Reshape into 4 dimensions
    lenSess         = length(SPM.Sess(sess).row);
    V4d             = zeros(evNum,1,1,lenSess);
    for t=1:lenSess
        V4d(:,1,1,t)    = V2d(t,:);
    end
    
    % Save nii-file
    evBindFile      = [evFolder, 'eigenvariates_sess_', num2str(sess), '.nii'];
    niftiwrite(V4d, evBindFile);

end
