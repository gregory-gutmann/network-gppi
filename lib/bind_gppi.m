%% Bind gppi contrasts for all subject of spm t- or F-values into single mat file
% Gregory Gutmann (25.08.2023)

function bind_gppi(conFolder,subjectList,contrastsInfo)

% Get SPM contrasts
spmDirs         = dir([conFolder '**\spm*.nii']);
contrasts       = {spmDirs.name};
contrasts       = sort(unique(contrasts));

% Iterate over contrasts
for c=1:length(contrasts)

    % Create empty matrix
    subIncludedList = [];
    genConMat       = double.empty(0,0,0);

    % SPM contrast
    spmContrast     = contrasts{c};
    spmContrast     = extractBefore(spmContrast,'.nii');

    % Iterate over subjects
    for s=1:length(subjectList)
        sub             = char(subjectList(s));
        
        % Iterate over regions and add contrast values
        estFiles        = dir([conFolder,sub,filesep,'gppi',filesep,'estimates', ...
            filesep,'*',filesep,spmContrast,'.nii']);
        subConMat       = []; 
    
        for e=1:length(estFiles)
            conFile         = [estFiles(e).folder,filesep,spmContrast,'.nii'];
            conData         = spm_data_read(conFile);
            subConMat       = [subConMat; conData'];
        end
    
        % Save in overarching structure
        try
            dim             = size(genConMat,3);
            genConMat(:,:,dim+1) = subConMat;
            subIncludedList = [subIncludedList; sub];
        catch
            disp(['error for: ', sub]);
        end
    
    end

    % Save matrix
    save([conFolder, 'ngppi_mat_' contrastsInfo(c).name],'genConMat','subIncludedList');

end

