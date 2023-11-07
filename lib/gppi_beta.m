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
seed, previous create target eigenvariates are used respectivly. Unlike the
seed eigenvariates, these are not filtered or withened and cofounds were 
not removed.

Comparison between SPM.mat for original datan and eigenvariates are noted 
(e for equal and u for unequal) 
%}

function errorRois = gppi_beta(ntwFolder, roiList)

errorRois           = {};

for r=1:length(roiList)
    
    % Set-up
    roiFile             = roiList{r};
    roi                 = roiFile(1:(end-4));             
    
    try
        % Load in EV-SPM
        load([ntwFolder,'eigenvariates',filesep,'SPM.mat'])

        % Change working directory
        SPMPPI.swd          = [ntwFolder,'gppi',filesep,'estimates',...
            filesep,roi,filesep];
    
        % Hameodynamic response function (unq., needs timing of EV-SPM)
        SPMPPI.xBF          = SPM.xBF;      

        % Data sets (unq., EV-SPM refers to EV-Nifti)    
        SPMPPI.xY           = SPM.xY;  

        % Number of scans (equal)
        SPMPPI.nscan        = SPM.nscan;

        % Used SPM version (equal)
        SPMPPI.SPMid        = SPM.SPMid;    

        % Form of non-sphericity (equal)
        SPMPPI.xVi.form     = SPM.xVi.form;

        if ischar(SPM.xVi.form) && strcmp(SPM.xVi.form,'i.i.d')
            SPMPPI.xVi.form     = 'none';
        end 

        % Global variate structure: mean scaling & normalization (equal)
        SPMPPI.xGX.iGXcalc  = SPM.xGX.iGXcalc;
        SPMPPI.xGX.sGXcalc  = SPM.xGX.sGXcalc;
        SPMPPI.xGX.sGMsca   = SPM.xGX.sGMsca;

        % High pass filter cutoff and RT (equal)
        for i=1:numel(SPMPPI.nscan)
            SPMPPI.xX.K(i).HParam   = SPM.xX.K(i).HParam;   %(same)
            SPMPPI.xX.K(i).RT       = SPM.xX.K(i).RT;       %(same)
        end
        
        % Session structure containg also design information. Covariates/
        % regressor information are switched for created gPPI parameters
        % (SPMs unqueal, but EV-SPM contains correct timing)
        for sess=1:numel(SPM.Sess)
            load([ntwFolder,'gppi',filesep,'parameters',filesep,'PPI_', ...
                roi,'_sess_',num2str(sess),'.mat']);
            SPMPPI.Sess(sess).U     = SPM.Sess(sess).U;
            SPMPPI.Sess(sess).C.C   = [OUT.PPI.C OUT.Y.C OUT.C.C];
            SPMPPI.Sess(sess).C.name= [OUT.PPI.name OUT.Y.name OUT.C.name];
        end

        % Create ROI-specifc folder for estimation
        try
            mkdir(SPMPPI.swd)
        end

        % Switch working directory and save both SPMs
        cd(SPMPPI.swd)
        
        % Delete any existing files
        delete beta_00*
        delete ResMS.*
        delete RPV.*
        delete mask.*
        
        % Rename to SPMs, SPM now refers to newly created gPPI-SPM
        SPM1                = SPM; clear SPM
        SPM                 = SPMPPI; clear SPMPPI

        % Configures the design matrix, data specification and
        % filtering for consecutive analysis
        SPM                 = spm_fmri_spm_ui(SPM);
        
        % Disable threshold masking
        SPM.xM.T(:)         = -Inf;  
        SPM.xM.TH(:)        = SPM1.xM.TH(:);
       
        % [Re]ML Estimation of a General Linear Model
        % (In)depentend variables are whitened and filtered during this step
        SPM                 = spm_spm(SPM);      

    catch
        disp(['Error for ',roi])
        errorRois = [errorRois,roi];
        
    end
end

save([ntwFolder,'gppi',filesep,'estimates',filesep,'errorRoisBeta'],'errorRois');
