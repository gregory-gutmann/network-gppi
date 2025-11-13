%% Computes distribution of connectome size based on network brain statistic 
%% for one-sample t-tests
% Gregory Gutmann (28.02.2024)

%{
NBS for one-sample t-test. For every iteration, half of participants are 
randomly drawn and their values multiplied with -1. One-sample t-tests 
are then computed for every connection and the resulting connectivity
matrix thresholded. 

The size (i.e. number of connections) of the largest connectoms are extracted  
and form over all iterations a distribution for which a p-value for the 
connectome of interest can be derived.
The approach is based upon Network Brain Statistics by Zalesky et al. (2010).

Because of the high number of parallel test I had to compute the t-tests
in matrix form.


Arguments: 

X               - 3-dimensional connectivity matrix (subjects alongs third dimension)
iteration       - number of iteration
supra_threshold - p-value threshold 

%}

function nbs_cdf = nbs_t_test_1s(data, iteration, supra_threshold)

% Preparations
distribution    = [];

% Group size
N               = size(data,3);
sqrt_n          = sqrt(N);

for iter=1:iteration
    
    % Randomized variable 
    rand            = randi([0 1],[1,1,N]).*2-1;
    
    % Multiply randomized variable with data set
    X                = data.*rand;
    
    % Mean and variation of connectivity matrix
    N               = size(X,3);
    X_m             = mean(X,3);
    X_sd            = sqrt((sum((X-X_m).^2,3))/(N-1));
       
    % T-values
    T               = X_m./(X_sd/sqrt_n);

    % Get p-values
    S               = tcdf(T,N-1);
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

% Transform sampple distribution to relativ cumulative distribution 
% for number of connections (p-value). 
hist_dist       = hist(distribution,unique(distribution));
relativ_dist    = hist_dist/sum(hist_dist);
nbs_cdf         = cumsum(relativ_dist);

