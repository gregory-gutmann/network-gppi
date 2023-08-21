%% Visualising gppi-matrix
% Gregory Gutmann (14.08.2023)

%% Needs to be changed to gppi-network folder
% Change wd to folder that contains lib- and tutorial-folder
wkdir           =  '/Users/gregory/Arbeit/gppi-network-main/';
% Adds file separator if necessary
if wkdir(end) ~= filesep
    wkdir           = [wkdir,filesep];
end

%% Brainnettome (all)
% Load in mats
mats            = load([wkdir, 'tutorial',filesep,'gppi-matrizes.mat'])

% Choose matrix for selecting wanted rows and columns
mat             = mats.ppi_hi_over_low;

%% Create filter index
% Subset for most significant regions based on row- and colsums (based on PPI.mat)
sums            = sum(mat.^2,2)+sum(mat.^2,2)';
sortsum         = sort(sums);
cutoffval       = sortsum(ceil(length(sums)*0.915));
indexSums       = find(sums>cutoffval);

% Select on most significant single values
sigSort         = sort(abs(mat(:)));
sigVals         = maxk(sigSort,20);
sigFilter       = mat>=min(sigVals) | mat<=max(-sigVals);
[sigRows, sigCols, sigValues] = find(mat.*sigFilter);


%% Colormap and Visual
posMax = max(mat,[],'all');
negMax = -min(mat,[],'all');
maxVal = max(posMax,negMax);
ceil(maxVal);

gradient_b  = (0:0.01:1);
green_b     = 1-gradient_b;
red_b       = 1-gradient_b;       
blue_b      = ones(1,length(green_b));
gppi_b       = [red_b' green_b' blue_b'];

gradient_r  = (0:0.01:1);
green_r     = gradient_r;
blue_r      = gradient_r;
red_r       = ones(1,length(green_r));
gppi_r       = [red_r' green_r' blue_r'];

gppi         = [gppi_r;gppi_b];


%% Plot map
% Set-up
mat             = mats.ppi_hi_over_low; % change for different maps
rows            = unique(sigRows);
cols            = unique(sigCols);

% Load in roi-names
load([wkdir, 'tutorial',filesep,'templates',filesep,'atlas.mat'])
roinames        = {atlas.Name};

% Plot all (change mat with filter)
heat            = heatmap(roinames(cols),roinames(rows),mat(rows,cols));
heat.XLabel     = 'Targets';
heat.YLabel     = 'Seeds';
colormap(gppi)              
clim([-1 1]*ceil(maxVal))



