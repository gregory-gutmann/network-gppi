%% Computes distribution of connectome size based on network brain statistic 
%% for correlations
% Gregory Gutmann (05.02.2024)

%{
For n permutations matching between coefficients are re-sorted.
Correlations are then computed for every connection and the resulting connectivity
matrix thresholded. 

The size (i.e. number of connections) of the largest connectoms are extracted  
and form over all iterations a distribution for which a p-value for the 
connectome of interest can be derived.
The approach is based upond Network Brain Statistics by Zalesky et al. (2010).

Because of the high number of parallel test I had to compute the
correlations in matrix form.


Arguments: 

X               - 3-dimensional connectivity matrix (subjects alongs third dimension)
y               - external variable with which connectivities are correlated
iteration       - number of iteration
supra_threshold - p-value threshold 

%}

function [nbs_cdf, N] = nbs_correlation(X, var, iteration, supra_threshold)

% Preparations
distribution    = [];

% Remove NaNs
X               = X(:,:,~isnan(var));
var             = var(~isnan(var));

% Mean and variation of connectivity matrix
N               = size(X,3);
X_m             = mean(X,3);
X_sd            = sqrt((sum((X-X_m).^2,3))/(N-1));

% Coefficient for connectivity matrix
X_coef          = (X - X_m)./X_sd;

for iter=1:iteration

    % Reordering of correlation variable
    y               = var(randperm(N));
    y               = reshape(y,[1,1,N]);

    % Coefficient for variable
    y_coef          = (y - mean(y))./std(y);
       
    % Correlation
    R               = sum(X_coef.*y_coef,3)./(N-1);

    % Get p-values
    T               = (sqrt(N-2).*R)./sqrt(1-R.^2);
    S               = tcdf(T,N-2);
    P               = 2 * min(S,1-S);

    % Threshold p-map
    conn_map        = (P <= supra_threshold);
    
    % Transform into graph   
    conn_graph      = digraph(conn_map);
    
    % Get number of links within connectomes
    [bins,binsizes] = conncomp(conn_graph,'Type','weak');
    outs            = outdegree(conn_graph);
    ins             = indegree(conn_graph);

    links           = [];
    for b=1:max(bins)
        l               = sum((outs(bins==b) + ins(bins==b))/2);
        links           = [links l];
    end
    
    % Add max links to overall distribution
    distribution    = [distribution max(links)];

end

% Transform sample distribution to relativ cumulative distribution 
% for number of connections (p-value). 
hist_dist       = hist(distribution,unique(distribution));
relativ_dist    = hist_dist/sum(hist_dist);
nbs_cdf         = cumsum(relativ_dist);


