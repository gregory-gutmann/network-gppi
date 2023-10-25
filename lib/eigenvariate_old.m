%% Extract Timeseries Data from all ROI(s)
% Gregory Gutmann (15.11.22)

%{
% Heavily based on timeseries_extract.m script written by Donald G. McLaren
% and Aaron Schulz (part of PPPI-package)
    % $Id: timeseries_extract.m
    % Copyright (c) 2011, Donald G. McLaren and Aaron Schultz
    % Donald G. McLaren and Aaron Schultz

%}


function xY = extract_eigenvariate(fstFolder,ntwFolder,contAdj,roiList,roiSubFolder)

% Create result folder
try
    mkdir([ntwFolder, 'eigenvariates']);
end

% Set-up
load([fstFolder, 'SPM.mat']);
sessions        = numel(SPM.Sess);

for sess=1:sessions

    for r=1:length(roiList)
        
        %% Preparations
        roi             = roiList{r};
        roiName         = roi(1:(length(roi)-4));
       
        clear xY
        [xY,errorchk]   = set_mask(SPM,[roiSubFolder,roi],roiName,ntwFolder);
        numvox          = size(xY.XYZmm,2);
        
        clear xY.y xY.yy xY.u xY.v xY.s xY.X0
        xY.Sess         = sess;
        xY.Ic           = contAdj;     
        
        %{
        if ~isnumeric(P.contrast)
            xY.Ic=str2double(P.contrast);
        else
            xY.Ic=P.contrast;
        end
        %}    
        
        %-Get voxel numbers that are in VOI
        xSPM.hdr        = spm_vol([SPM.swd filesep SPM.VM.fname]);
        [xSPM.Y, xSPM.XYZmm] = spm_read_vols(xSPM.hdr);
        mXYZ            = inv(xY.mask.mat)*[xSPM.XYZmm;ones(1,size(xSPM.XYZmm,2))]; %#ok<*MINV> % pixel coordinates
        tmpQ            = spm_sample_vol(xY.mask,mXYZ(1,:),mXYZ(2,:),mXYZ(3,:),0);
        tmpQ(~isfinite(tmpQ)) = 0;
        Q               = find(tmpQ);
        
        [R,C,S]         = ndgrid(1:xSPM.hdr.dim(1),1:xSPM.hdr.dim(2),1:xSPM.hdr.dim(3));
        xY.XYZ          = [R(:)';C(:)';S(:)'];
        xY.XYZ          = xY.XYZ(:,Q);
        clear R C S
        
        %% For seed-eigenvariate
        % spm_regions.m was the source of most of the code below.
        % get Data
        y               = spm_get_data(SPM.xY.VY,xY.XYZ);
        y               = spm_filter(SPM.xX.K,SPM.xX.W*y);
       
        % computation
        % parameter estimates: beta = xX.pKX*xX.K*y
        tmpdir          = pwd;
        cd(SPM.swd)
        beta            = spm_get_data(SPM.Vbeta,xY.XYZ);
        cd(tmpdir)
        
        % subtract Y0 = XO*beta,  Y = Yc + Y0 + e
        if xY.Ic~=0
            y = y-spm_FcUtil('Y0',SPM.xCon(xY.Ic),SPM.xX.xKXs,beta);
        end

        [xY,y]          = get_confounds(SPM,xY,y);
        
        % compute regional response in terms of first eigenvariate 
        [m n]   = size(y);
        if m > n
            [v s v]         = svd(y'*y);
            s               = diag(s);
            v               = v(:,1);
            u               = y*v/sqrt(s(1));
        else
            [u s u]         = svd(y*y');
            s               = diag(s);
            u               = u(:,1);
            v               = y'*u/sqrt(s(1));
        end
        d               = sign(sum(v));
        u               = u*d;
        v               = v*d;
        Y               = u*sqrt(s(1)/n);
        
        % set in structure
        xY.y                = y;
        xY.yy               = transpose(mean(transpose(y))); %average (not in spm_regions)
        xY.u                = Y; %eigenvariate
        xY.v                = v;
        xY.s                = s;
        
        %% For target-eigenvariate (without subtract Y0 = XO*beta)
        % get data
        yt              = spm_get_data(SPM.xY.VY,xY.XYZ);
        yt              = spm_filter(SPM.xX.K,SPM.xX.W*yt);

        [xY,yt]         = get_confounds(SPM,xY,yt);

        % compute regional response in terms of first eigenvariate 
        [m n]   = size(yt);
        if m > n
            [v s v]         = svd(yt'*yt);
            s               = diag(s);
            v               = v(:,1);
            u               = yt*v/sqrt(s(1));
        else
            [u s u]         = svd(yt*yt');
            s               = diag(s);
            u               = u(:,1);
            v               = yt'*u/sqrt(s(1));
        end
        d               = sign(sum(v));
        u               = u*d;
        v               = v*d;
        Yt              = u*sqrt(s(1)/n);

        % set in structure
        xY.t                = Yt; %eigenvariate
     
        % save
        resultFolder    = [ntwFolder,'eigenvariates',filesep];
        save([resultFolder,roiName,'_sess_',num2str(sess)],'xY', '-v6');
        
        clear xY XYZ hdr img beta y d u v Y s

    end

end



