%% Coordinates gppi-network functions
% Gregory Gutman (05.01.24)

%{
Script coordinates function of gppi-network for a more user-friendly 
approach. Can be easily adapted for different purposes as e.g., usage with
high-performance computing (HPC). Usage of HPC might be faviorable if you
analyse full connectivity and have many subjects. In this case, subjects
can be processes in parallel by adapting the for-loop.
%}

function ngppi(N)

%% Preparations
% Add filesep to end of paths (if necessary)
if N.roiFolder(end) ~= filesep; N.roiFolder = [N.roiFolder,filesep]; end
if N.glmFolder(end) ~= filesep; N.glmFolder = [N.roiFolder,filesep]; end
if N.ngppiFolder(end) ~= filesep; N.ngppiFolder = [N.ngppiFolder,filesep]; end


%% Iterate over subjects
bind            = 0;
for s = 1:length(N.subjectList)

    try
        % Subject-specfic parameters
        sub             = N.subjectList{s};
        disp(['Run gppi-network for subject: ' sub]);
        fstFolder       = [N.glmFolder,sub,filesep];
        ntwFolder       = [N.ngppiFolder,sub,filesep];
        roiSubFolder    = [ntwFolder,'roi_masks',filesep];
    
        % If wanted (sphere exist), adapts general roi-masks to individual mask 
        % by drawing a volumne around defined peaks. Otherwise whole ROI is
        % used
        step            = ['Step 1. Create specific ROI masks for subject: ' sub];
        disp(step);
        if exist('sphere','var')
            roi_peak_masks(fstFolder,ntwFolder,N.roiFolder,N.roiList,N.sphere, ...
                N.sphereInfo,N.contPeak,N.directionList);
        else
            roi_masks(fstFolder,ntwFolder,N.roiFolder,N.roiList)
        end
    
        % Extract eigenvariates (might take a little bit)
        %   creates seed- and target-eigenvariate
        step            = ['Step 2. Extract eigenvarietes for ROIs (might take ' ...
            'a little bit) for subject: ' sub]
        disp(step);
        eigenvariate(fstFolder,ntwFolder,N.contAdj,N.roiList,roiSubFolder);
    
        % Binds multiple eigenvariate.mat's into a single nifti
        step            = ['Step 3. Bind eigenvariates into single nifti for subject: ' sub];
        disp(step);
        eigenvariate2nii(fstFolder,ntwFolder);
    
        % Creates SPM.mat for eigenvariate.nii containing all relevant
        % information
        % e.g. design structure
        step            = ['Step 4. Create SPM-structure for eingenvariate nifti for subject: ' sub];
        disp(step);
        eigenvariate_glm(fstFolder,ntwFolder);
    
        % Creates gppi parameters for all eigenvariates including design
        % variables, deconvoluded seed timeseries, interaction between design variables and seed time series
        step            = ['Step 5. Create gppi parameters for all eigenvariates for subject: ' sub];
        disp(step);
        gppi_parameter(fstFolder, ntwFolder, N.tasks);
    
        % Apply gppi parameters on target rois to get beta values for each individual
        step            = ['Step 6. Compute gppi beta values for subject: ' sub];
        disp(step);
        gppi_beta(ntwFolder, N.roiList);
    
        % Compute gppi contrasts 
        step            = ['Step 7. Compute gppi contrasts for subject: ' sub];
        disp(step);
        gppi_contrasts(ntwFolder,N.roiList,N.contrasts);
        bind            = 1;

    catch
        disp(['Error happened for: ' step])
    end
end

% Bind estimates for different rois into single matrix
% bind roi estimates of spm t- or F-values into single nifti
if bind
    try
        step            = 'Step 8. Bind gppi contrasts for all subjects';
        disp(step);
        bind_gppi(N.ngppiFolder,N.subjectList,N.contrasts);
    catch
        disp(['Error happened for: ' step]);
    end
end

% Save parameter settings
save([N.ngppiFolder 'ngppi-settings'],'N');

end
