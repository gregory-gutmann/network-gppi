%% Visualising gppi-matrix
% Gregory Gutmann (14.08.2023)

%% IMPORTANT: The script is written for all connections, adapt 'roinames' 
%% If you choose the options with only 20 rois

%% Needs to be changed to gppi-network folder
% Change wd to folder that contains lib- and tutorial-folder
wkdir           =  'C:\Users\grego\Desktop\network-gppi-main';
% Adds file separator if necessary
if wkdir(end) ~= filesep
    wkdir           = [wkdir,filesep];
end

%% Brainnettome (all)
% Load ppi-constrast
load([wkdir, 'tutorial',filesep,'gppi-network',filesep, ...
    'ngppi_mat_ppi-hi_over_low.mat']);
mat_ppi         = genConMat;

% Load in roi-names
load([wkdir, 'tutorial',filesep,'templates',filesep,'atlas.mat'])
roinames        = {atlas.Name};
roinames        = strrep(roinames,'_','-');
%roinames        = roinames(1:20); % Adapt to rois used

%% Create filter index
% Subset for most significant regions based on row- and colsums (based on PPI.mat)
sums            = sum(mat_ppi.^2,2)+sum(mat_ppi.^2,2)';
sortsum         = sort(sums);
cutoffval       = sortsum(ceil(length(sums)*0.915));
indexSums       = find(sums>cutoffval);

% Select on most significant single values
sigSort         = sort(abs(mat_ppi(:)));
sigVals         = maxk(sigSort,30); % change number if more or less significant 
                        % values should be included
sigFilter       = mat_ppi>=min(sigVals) | mat_ppi<=max(-sigVals);
[sigRows, sigCols, sigValues] = find(mat_ppi.*sigFilter);


%% Colormap and Visual
maxVal          = max(abs(mat_ppi),[],'all');

gradient_b      = (0:0.01:1);
green_b         = 1-gradient_b;
red_b           = 1-gradient_b;       
blue_b          = ones(1,length(green_b));
gppi_b          = [red_b' green_b' blue_b'];

gradient_r      = (0:0.01:1);
green_r         = gradient_r;
blue_r          = gradient_r;
red_r           = ones(1,length(green_r));
gppi_r          = [red_r' green_r' blue_r'];

evening         = [gppi_r;gppi_b];

%% Plot ppi_hi_over_low
% Set-up
rows            = unique(sigRows);
cols            = unique(sigCols);

% Plot all (change mat with filter)
heat            = heatmap(roinames(cols),roinames(rows),mat_ppi(rows,cols));
heat.XLabel     = 'Targets';
heat.YLabel     = 'Seeds';
colormap(evening);              
clim([-1 1]*ceil(maxVal));

% Save figure
saveas(gcf,[wkdir,'tutorial',filesep,'gppi-network',filesep,'ppi_hi_over_low.png']);

%% Plot hi_over_low
% load psy-contrasts
load([wkdir, 'tutorial',filesep,'gppi-network',filesep, ...
    'ngppi_mat_hi_over_low.mat']);
mat_psy         = genConMat;
rows            = unique(sigRows);
cols            = unique(sigCols);

% Plot all (change mat with filter)
heat            = heatmap(roinames(cols),roinames(rows),mat_psy(rows,cols));
heat.XLabel     = 'Targets';
heat.YLabel     = 'Seeds';
colormap(evening);             
clim([-1 1]*ceil(maxVal));

% Save figure
saveas(gcf,[wkdir,'tutorial',filesep,'gppi-network',filesep,'hi_over_low.png']);

%% Plot roi_ev
% load seed-contrast
load([wkdir, 'tutorial',filesep,'gppi-network',filesep, ...
    'ngppi_mat_roi_ev.mat']);
mat_roi         = genConMat;
rows            = unique(1:50);
cols            = unique(1:50);

% Plot all (change mat with filter)
heat            = heatmap(rows,cols,mat_roi(rows,cols),'CellLabelColor','none');
heat.XLabel     = 'Targets';
heat.YLabel     = 'Seeds';
grid off;

% Save figure
saveas(gcf,[wkdir,'tutorial',filesep,'gppi-network',filesep,'roi_ev.png']);
