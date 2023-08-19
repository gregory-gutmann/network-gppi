%% Estimates firstlevel gPPI-contrasts values
% Gregory Gutmann (09.01.22)

%{
Based on spm_contrasts_PPI.m script written by Donald G. McLaren
and Aaron Schulz (part of PPPI-package)
    $Id: spm_estimate_PPI.m
    Copyright (c) 2011,2012 Donald G. McLaren and Aaron Schultz
    Donald G. McLaren and Aaron Schultz
    This product includes software developed by the Harvard Aging Brain Project.

Changes: Cut-down to basic essentuals, contrast-vector created manually in 
main scipt
Contrasts contains 'name', 'stat', 'c' (contrast weights)
Validated with Version using SPM matlabbacth (which I validated using
regular PPPI pipeline)
%}

function errorRois      = gppi_contrasts(ntwFolder,roiList,contrasts);

errorRois               = {}

for r=1:length(roiList)
    
    % Set-up
    roiFile             = roiList{r};
    roi                 = roiFile(1:(end-4));             
    
    try
        load([ntwFolder,'gppi',filesep,'estimates',filesep, ...
            roi,filesep,'SPM.mat']);

        %Configure Contrasts
        ind                 = zeros(length(contrasts),1);
        for ii = 1:length(contrasts)
            if mean(contrasts(ii).c==0)~=1; 
                ind(ii)         = 1; 
            end
        end
        
        contrasts           = contrasts(ind==1);
        for ii = 1:length(contrasts)
            xCon(ii)            = spm_FcUtil('Set',contrasts(ii).name,contrasts(ii).stat,'c',contrasts(ii).c,SPM.xX.xKXs);
        end
        
        %Compute Contrasts
        try
            init=length(SPM.xCon);
        catch
            init=0;
        end
        if init~=0
            SPM.xCon(init+1:init+length(xCon)) = xCon;
        else
            SPM.xCon = xCon;
        end
        SPM = spm_contrasts(SPM,init+1:length(SPM.xCon));
        
    catch
        disp(['Error for ',roi])
        errorRois = [errorRois,roi];
        
    end
end


