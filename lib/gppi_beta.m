%% Estimates firstlevel gPPI-beta values
% Gregory Gutmann (28.11.22)

%{
Based on spm_estimate_PPI.m script written by Donald G. McLaren
and Aaron Schulz (part of PPPI-package)
    $Id: spm_estimate_PPI.m
    Copyright (c) 2011,2012 Donald G. McLaren and Aaron Schultz
    Donald G. McLaren and Aaron Schultz
    This product includes software developed by the Harvard Aging Brain Project.

Former Important change: Instead of using the whole-brain as voxelwise target
seed, the previous filtered eigenvariates are used respectivly
Not anymore: Scaling factor 1 and Offset 0 were added to pinfo (?)
%}


function errorRois = gppi_beta(ntwFolder, roiList)

errorRois           = {};

for r=1:length(roiList)
    
    % Set-up
    roiFile             = roiList{r};
    roi                 = roiFile(1:(end-4));             
    
    try
        load([ntwFolder,'eigenvariates',filesep,'SPM.mat'])
        SPMPPI.swd          = [ntwFolder,'gppi',filesep,'estimates',...
            filesep,roi,filesep];
    
        % Get needed fields from task model
            % (...): Comaprison between SPM.mat of normale and eigenvariates SPM 
        SPMPPI.xBF          = SPM.xBF;      % basis function (different)
        SPMPPI.xY           = SPM.xY;       % data (different)
        SPMPPI.nscan        = SPM.nscan;    % number of scans (same)
        SPMPPI.SPMid        = SPM.SPMid;    % spm version (same)
        SPMPPI.xVi.form     = SPM.xVi.form; % form of non-sphericity (same)
        if ischar(SPM.xVi.form) && strcmp(SPM.xVi.form,'i.i.d')
            SPMPPI.xVi.form     = 'none';
        end 
        SPMPPI.xGX.iGXcalc  = SPM.xGX.iGXcalc;  % global normalization (same)
        SPMPPI.xGX.sGXcalc  = SPM.xGX.sGXcalc;  % ?? (same)
        SPMPPI.xGX.sGMsca   = SPM.xGX.sGMsca;   % ?? (same)
        for i=1:numel(SPMPPI.nscan)
            SPMPPI.xX.K(i).HParam   = SPM.xX.K(i).HParam;   %(same)
            SPMPPI.xX.K(i).RT       = SPM.xX.K(i).RT;       %(same)
        end
        
        for sess=1:numel(SPM.Sess)
            load([ntwFolder,'gppi',filesep,'parameters',filesep,'PPI_',roi,'_sess_',num2str(sess),'.mat']);
            SPMPPI.Sess(sess).U     = SPM.Sess(sess).U;     %(different)
            SPMPPI.Sess(sess).C.C   = [OUT.PPI.C OUT.Y.C OUT.C.C];
            SPMPPI.Sess(sess).C.name= [OUT.PPI.name OUT.Y.name OUT.C.name];
        end
        
        %{
        % scaling factors (added by GG, correct?)
        for n=1:sum(SPM.nscan)
            SPM.xY.VY(n).pinfo(1:2)   = [1;0];
        end
        %}

        % Estimate PPI 1st Level Model
        try
            cd(SPMPPI.swd)
        catch
            mkdir(SPMPPI.swd)
            cd(SPMPPI.swd)
        end
        save SPM SPMPPI
        
        % Delete any existing files
        delete beta_00*
        delete ResMS.*
        delete RPV.*
        delete mask.*
        
        % Make design and estimate, rename to SPM
        SPM1                = SPM; clear SPM
        SPM                 = SPMPPI; clear SPMPPI
        SPM                 = spm_fmri_spm_ui(SPM);
        
        SPM.xM.T(:)         = -Inf;  %% disable threshold masking
        SPM.xM.TH(:)        = -Inf;  %%SPM1.xM.TH(:);

        %{
        V                   = spm_vol([ntwFolder,'roi_masks',filesep,roiFile]);
        SPM.xM.VM           = V;
        %}
            
        SPM                 = spm_spm(SPM);      
        
    catch
        disp(['Error for ',roi])
        errorRois = [errorRois,roi];
        
    end
end

save([ntwFolder,'gppi',filesep,'estimates',filesep,'errorRoisBeta'],'errorRois');
