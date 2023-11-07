 %% Adapts general roi-masks to individual mask (cuts outlying corners)
% Gregory Gutmann (20.04.2023)

%{
Creates roi-masks that draws a sphere around a positive or negative
peak – depending on the defined direction – for a choosen contrast within a
specific regions. Individual brain outline is also considered. Process is
way faster then an equal implementation in spm (3 s vs. 2 min for 28
rois)
%}

function roi_peak_masks(fstFolder,ntwFolder,roiFolder,roiList,sphere,sphereInfo,contPeak,directionList)

%% Set-up
% Create folder
try
    mkdir([ntwFolder,'roi_masks']);
end

% Create sphere-mask
sphereMask      = spm_read_vols(sphereInfo) .* 0;
s               = round(size(sphere,1)/2,TieBreaker="tozero"); 

% Read in brain-masks
brainInfo       = spm_vol([fstFolder,'mask.nii']);
brain           = spm_read_vols(brainInfo);
    
% Read in contrast-image
contInfo        = spm_vol([fstFolder,contPeak]); 
cont            = spm_read_vols(contInfo);

% Create template mask-info structure
info            = brainInfo;

% Create template for peak-infos
peaks           = struct();
peaks.fname     = ntwFolder;


%% For-loop that iterates over regions
for r=1:length(roiList)

    % Get roi-name
    roiFile         = roiList{r};
    roiName         = roiFile(1:(length(roiFile)-4));
    
    % Read in roi-mask
    roiInfo         = spm_vol([roiFolder,roiFile]);
    roi             = spm_read_vols(roiInfo);
    
    % Mask roi-mask with brain-mask
    roiBrain        = brain .* roi;
    
    % Mask contrast-image with roi-mask and subject-mask
    contRoi         = cont .* roiBrain;
    
    % Get peak (positive or negative)
    [maxPeak, maxIndex] = max(contRoi,[],'all');
    [minPeak, minIndex] = min(contRoi,[],'all');
    
    % Get peak indices ()
    [px, py, pz] = ind2sub(size(contRoi), maxIndex);
    [nx, ny, nz] = ind2sub(size(contRoi), minIndex);
    
    % Create peak depentend of predefined direction of ROI
    if directionList(r)
        valPeak     = maxPeak;
        [x, y, z]   = deal(px, py, pz);
    else 
        valPeak     = minPeak;
        [x, y, z]   = deal(nx, ny, nz);
    end

    % Create peak-centered sphere mask
    spherePeakMask  = sphereMask;
    try
        spherePeakMask(x-s:x+s,y-s:y+s,z-s:z+s) = sphere;
    catch
        disp('error: sphere centre to close to dimension bonds')
    end
    
    % Mask roi-brain-mask with peak-centered sphere-mask
    roiBrainSphere  = logical(roiBrain .* spherePeakMask);

    % Save roi-brain-sphere-mask
    info.fname      = [ntwFolder,'roi_masks',filesep,roiFile];
    info.private.dat.fname = info.fname;
    spm_write_vol(info,roiBrainSphere);

    % Put in positive and negative peaks and corresponding coordinates
    peaks.(roiName).peak  = valPeak;
    peaks.(roiName).cood  = [x, y, z];    
    peaks.(roiName).ppeak = maxPeak;
    peaks.(roiName).pcood = [px, py, pz];
    peaks.(roiName).npeak = minPeak;
    peaks.(roiName).ncood = [nx, ny, nz];

end

% save peak information
save([ntwFolder,'roi_masks',filesep,'peaks.mat'], 'peaks')

