%% Visualising gppi-matrix and save created image
% Gregory Gutmann
% Colormap based on autmn (positive) and winter (negative) colormap

%{

Arguments: 

mat             - value matrix (e.g. t-values)
roinames        - list of region names
outputname      - name of output file

%}

function visualize_conns(mat,roinames,outputname)

set(gcf, 'Position', get(0, 'Screensize'));

% Absolute value of least significant connection
thresh_mat          = abs(mat);
thresh_mat(thresh_mat == 0) = NaN;                                           
thresh              = min(thresh_mat,[],'all'); 

% Filter only comlumns and rows with min. one significant value
sig_mat     = double((mat >= thresh) | (mat <= -thresh));
sig_rows    = (sum(sig_mat,2) >= 1);
sig_cols    = (sum(sig_mat,1) >= 1);

% Filter data matrix
mat         = mat(sig_rows, sig_cols);

% Filter row and column names
rownames    = roinames(sig_rows');
colnames    = roinames(sig_cols);


% Create colormap with unsignificant values coloured black
ceiling     = max(abs(mat),[],'all');
stepsize    = (ceiling-thresh)/256;
nsteps_bla  = floor(thresh/stepsize);
if nsteps_bla == 0
    nsteps_bla  = 1
end
black       = zeros(2*nsteps_bla,3);
finanno     = [flip(autumn);black;winter]; 

% Plot connections (change mat with filter)
heat            = heatmap(colnames,rownames,mat,'CellLabelColor','none');
heat.XLabel     = 'Target-Regions';
heat.YLabel     = 'Seed-Regions';
colormap(finanno);
clim([-1 1]*ceiling)
grid off;
set(gcf,'units','pixels','position',[300,300,1000,800])

% Save image
saveas(gcf,[outputname,'.jpg'])

end




