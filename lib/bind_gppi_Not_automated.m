%% Bind gppi contrasts for all subject of spm t- or F-values into single nifti
% Gregory Gutmann (25.08.2023)

function genConMat = bind_gppi(conFolder,spm_contrast)

% Subjectlist
subjectList     = dir([conFolder,'sub*']);
subjectList     = {subjectList.name};

% Create empty matrix
genConMat       = double.empty(0,0,0);
subIncludedList = [];

% Iterate over subjects
for s=1:length(subjectList)
    sub             = char(subjectList(s));
    
    % Iterate over regions and add contrast values
    estFiles        = dir([conFolder,sub,filesep,'gppi',filesep,'estimates', ...
        filesep,'*',filesep,spm_contrast,'.nii']);
    subConMat       = []; 

    for e=1:length(estFiles)
        conFile         = [estFiles(e).folder,filesep,spm_contrast,'.nii'];
        conData         = spm_data_read(conFile);
        subConMat       = [subConMat; conData'];
    end

    % Save in overarching structure
    try
        dim             = size(genConMat,3);
        genConMat(:,:,dim+1) = subConMat;
        subIncludedList = [subIncludedList; sub];
    catch
        disp(['error for: ', sub])
    end

end


% Save matrix
save([conFolder, 'gppi_all_', spm_contrast],'genConMat','subIncludedList') 

