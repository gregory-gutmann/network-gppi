%% Create turorial for examplary second-level analyses using NBS
% Gregory Gutmann (11.11.2025)

%{
This tutorial provides a possible pipeline to compute second-level effects,
evaluate them using network-based statistics (NBS), and create edge matrices to
visualize the surviving connections with the BrainNet Viewer. 
How BrainNet Viewer can be used is shortly explaned on the read-me page of the 
online tutorial. To make this tutorial work, you should only need to adapt 
the working directory.

This tutorial focuses on a group contrast using simulated data from a
study comparing reward processing in depressed patients and healthy
controls. The script can, however, easily be adopted to analyse task effects
(one-sample t-tests) or a correlations with an external variables. For all 
three methods, NBS functions are provided in the 'function' folder, which 
also contain more information on the specific computation process. 


For an examplary one-sample t-test, change ... 
... line 85 to: ttest(data(i,j,:));
... line 102 to: nbs_t_test_1s(data,1000,threshold);

For an examplary correlation , create a variable, e.g, var = normrnd(0,5,[1,80]) 
and change ...
... line 85-86 to:         
        [r p]               = corrcoef(data(i,j,:),var,'rows','pairwise');
        r_mat(i,j)          = r(2,1);
        p_mat(i,j)          = p(2,1); 
... line 102 to: nbs_correlation(data,var,1000,threshold);

As the variable is created randomly, it is very likely that no or only very 
few significant connections will survive the initial threshold. The opposite 
will be true for the one-sample t-test, for which large scale effects can 
be expected. Of course, it might also be helpful to change the output file
names.

Also, for NBS  I normally use 10,000 iterations. To shorten run time, I
only used 1,000 iterations in this script. 

%}

%==========================================================================
%% Preparations
%==========================================================================
% Update working directory to tutorial_scd_level folder
wkdir           = 'C:\Users\grego\Desktop\network-gppi-main\tutorial_scd_level\';

% Adds file separator if necessary
if wkdir(end) ~= filesep
    wkdir           = [wkdir,filesep];
end

% Add paths to functions
addpath([wkdir, 'functions'])

% Change working directory to subfolder data
cd([wkdir, 'data'])

% Load in important data
load('connectivity_data.mat');
data            = genConMat; % Connectivity data
    % subIncludedList contains a list of subjetcs (not needed here)
load('roinames-list.mat'); % Names for all nodes

% Seed for random processes (in NBS)
rng(173) 

% Separate into two groups
pat_data        = data(:,:,1:40);
con_data        = data(:,:,40:80);

%==========================================================================
%% Compute t- and p-value for every interaction 
%==========================================================================
% set-up variables 
nrow            = size(data,1);
ncol            = size(data,2);
t_mat           = zeros(nrow,ncol);
p_mat           = zeros(nrow,ncol);

% Here, as in the original article, unequal variance is used.
for i=1:nrow
    for j=1:ncol
        [h,p,ci,stats]      = ttest2(pat_data(i,j,:),con_data(i,j,:),'Vartype',"unequal");;
        t_mat(i,j)          = stats.tstat; 
        p_mat(i,j)          = p;
    end
end

% filter connections with threshold p < .001
threshold       = 0.001;
threshold_mat   = p_mat <= (threshold);    % Already for two-sided test accounted
conn_mat        = t_mat .* threshold_mat;


%==========================================================================
%% Network Brain Statistic (NBS)
%==========================================================================
% See script in functions-folder for an explanation of the arguments.
% Here I only used 1,000 iterations so it doesnt take so long (normally 10,000)
nbs             = nbs_t_test_2s(data, [40 40], 1000, threshold, 'unequal');
save('group_difference_nbs_cdf','nbs'); 

% Compute network sizes
conn_graph      = digraph(conn_mat,roinames);
[bins,binsizes] = conncomp(conn_graph,'Type','weak');
outs            = outdegree(conn_graph);
ins             = indegree(conn_graph);

% Number of links for different connectomes
links           = [];
for b=1:max(bins)
    l               = sum((outs(bins==b) + ins(bins==b))/2);
    links           = [links l];
end
network_sizes   = sort(links,"descend");

% Size of the largest network
largest_network = network_sizes(1)

% Compare largest network with nbs derived cumulative distribution function
try
    cdf         = nbs(largest_network);
catch
    cdf         = 1; % Should found network be larger then any in the NBS distribution
end

% NBS derived p-value of the largest network 
p_nbs           = 1 - cdf          

%{
The observed network, reflecting the difference between both groups, is
highly significant. It is larger then any network based on 1000 (or 10000)
random group assignments. 
The resulting p-value is p < .001 (p = 1-cdf = 0)
%}


%==========================================================================
%% Visualization of all connections
%==========================================================================
% Visualize all surviving connectivities in a heatmap
    % See script in functions-folder for more information
    % Image is automatically saved in wd
visualize_conns(conn_mat,roinames,'group_difference');

% Save connectivity matrix unchanged (for potential further processing)
dlmwrite('conn_edge.txt', conn_mat, 'delimiter', '\t');
movefile conn_edge.txt conn_edge.edge

% Save as simple edge matrix for better visualization with brainnetview
%   Only differentiates between positive and negative values
%   Matrix is transposed so arrows go from seed to target directions
conn_simple         = (conn_mat<0).*-1 + (conn_mat>0);
dlmwrite('all_connections_simple.txt', conn_simple', 'delimiter', '\t');
movefile all_connections_simple.txt all_connections_simple.edge


%==========================================================================
%% Visualization of central hubs
%==========================================================================
% Overview of central hubs (4+ significant connections)
conn_true       = int8(conn_mat ~= 0);
conn_num        = sum((conn_true + conn_true'),2);
hubs            = conn_num >= 4; % change if you want to include more or less hubs
table(roinames(hubs)',conn_num(hubs)) % shows region and # of connections

% Create matrix with central hubs connection
filter          = double(repmat(hubs,[1 246]) & repmat(hubs',[246 1]));
hubs_edges      = filter .* conn_mat;

% Save as simple transposed matrix
hubs_edges_st   = ((hubs_edges<0).*-1 + (hubs_edges>0))';
dlmwrite('central_hubs_simple.txt', hubs_edges_st, 'delimiter', '\t');
movefile central_hubs_simple.txt central_hubs_simple.edge


% Create an edge matrix for every central hub (7+ significant connections)
if ~exist([wkdir, 'data',filesep,'hubs'])
    mkdir 'hubs'
end
cd hubs
hubs                = conn_num >= 7; % change if you want to include more or less hubs
list                = 1:246;
hubs_index          = list(hubs);

% Iterate over central hubs
for i=(hubs_index)

    % Create filter for one central hub
    hubs_sel            = [zeros(i-1,1); 1; zeros(246-i,1)];
    filter              = double(repmat(hubs_sel,[1 246]) | repmat(hubs_sel',[246 1]));

    % Filter central hub
    hubs_edges          = filter .* conn_mat;
    hubs_edges_st       = ((hubs_edges<0).*-1 + (hubs_edges>0))';

    % Save connectivity matrix
    dlmwrite([roinames{i} '.txt'], hubs_edges_st, 'delimiter', '\t');
    movefile([roinames{i} '.txt'], [roinames{i} '.edge']);

end



