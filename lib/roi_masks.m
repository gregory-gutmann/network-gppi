 %% Adapts general roi-masks to individual mask (cuts outlying corners)
% Gregory Gutmann (01.12.2023)

function roi_peak_masks(fstFolder,ntwFolder,roiFolder,roiList)

%% Set-up
% Create folder
if ~exist([ntwFolder,'roi_masks'])
    mkdir([ntwFolder,'roi_masks']);
end

% Read in brain-masks
brainInfo       = spm_vol([fstFolder,'mask.nii']);
brain           = spm_read_vols(brainInfo);
    
% Create template mask-info structure
info            = brainInfo;

% Create template for peak-infos
peaks           = struct();
peaks.fname     = ntwFolder;


%% For-loop that iterates over regions
for r=1:length(roiList)

    % Get roi-name
    roiFile         = roiList{r};
    
    % Read in roi-mask
    roiInfo         = spm_vol([roiFolder,roiFile]);
    roi             = spm_read_vols(roiInfo);
    
    % Mask roi-mask with brain-mask
    roiBrain        = brain .* roi;
    
    % Save roi-brain-mask
    info.fname      = [ntwFolder,'roi_masks',filesep,roiFile];
    info.private.dat.fname = info.fname;
    spm_write_vol(info,roiBrain);

end
