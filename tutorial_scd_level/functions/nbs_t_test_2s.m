%% Computes distribution of connectome size based on network brain statistic 
%% for two-sample t-tests
% Gregory Gutmann (17.01.2024)

%{
For n iterations group allocation is randomized for defined group sizes. 
Two-sample t-test comparing both groups are then computed for every 
connection and the resulting connectivity matrix is thresholded. 

The size (i.e. number of connections) of the largest connectoms are extracted  
and form over all iterations a distribution for which a p-value for the 
connectome of interest can be derived.
The approach is based upon Network Brain Statistics by Zalesky et al. (2010).

Because of the high number of parallel test I had to compute the t-tests
in matrix form. Equal or non-equal variance is taken into account.


Arguments: 

data            - 3-dimensional connectivity matrix (subjects alongs third dimension)
group_sizes     - respected group sizes [a b]
iteration       - number of iteration
supra_threshold - p-value threshold 
varequagl       - is variance between groups equal  ('equal' or 'nonequal')

%}

function nbs_cdf = nbs_t_test_2s(data, group_sizes, iteration, supra_threshold, varequal)

% Preparations
distribution    = [];
nx              = group_sizes(1);
ny              = group_sizes(2);
group_fixed     = logical([ones(nx,1); zeros(ny,1)]);
sample_size     = nx + ny;

for iter=1:iteration

    % Group allocation
    group_random        = reshape(group_fixed(randperm(sample_size)),sample_size,1);
    X                   = data(:,:,group_random);
    Y                   = data(:,:,~group_random);

    % Mean values
    x_m                 = mean(X,3);
    y_m                 = mean(Y,3);

    % Standard deviations
    x_var               = (sum((X-x_m).^2,3))/(nx-1);
    y_var               = (sum((Y-y_m).^2,3))/(ny-1);

    % If variance between groups is unequal
    if strcmp(varequal, 'unequal')

        % Get t-values
        T                   = (x_m-y_m)./(sqrt(x_var/nx + y_var/ny));

        % Degrees of freedom (Satterthwaite's approximation)
        sw_num              = (x_var/nx + y_var/ny).^2;
        sw_denom_x          = (1/(nx-1))*((x_var/nx).^2);
        sw_denom_y          = (1/(ny-1))*((y_var/ny).^2);
        DF                  = sw_num./(sw_denom_x + sw_denom_y);
        
        % Get p-values
        p                   = tcdf(T,DF);
        p_filter            = p<.5;
        p_case_1            = p .* p_filter;
        p_case_2            = (1-p) .* (~p_filter);
        P                   = 2*(p_case_1 + p_case_2);

     % If variance between groups is equal
    elseif strcmp(varequal, 'equal')

        % Get t-values
        pooled_var          = ((nx-1)*x_var + (ny-1)*y_var)/(nx+ny-2);
        T                   = (x_m-y_m)./(sqrt(pooled_var/nx + pooled_var/ny));

        % DF
        DF                  = nx + ny - 2;

        % Get p-values
        p                   = tcdf(T,DF);
        p_filter            = p<.5;
        p_case_1            = p .* p_filter;
        p_case_2           = (1-p) .* (~p_filter);
        P                   = 2*(p_case_1 + p_case_2);

    else
        
        disp('!!!ErrorErrorError!!!');

    end

    % Threshold p-map
    conn_map            = (P <= supra_threshold);
    
    % Transform into graph   
    conn_graph          = digraph(conn_map);
    
    % Get number of links within connectomes
    [bins,binsizes]     = conncomp(conn_graph,'Type','weak');
    outs                = outdegree(conn_graph);
    ins                 = indegree(conn_graph);

    links               = [];
    for b=1:max(bins)
        l                   = sum((outs(bins==b) + ins(bins==b))/2);
        links               = [links l];
    end
    
    % Add max links to overall distribution
    distribution        = [distribution max(links)];

end

% Transform sample distribution to relativ cumulative distribution 
% for number of connections (p-value). 
hist_dist           = hist(distribution,unique(distribution));
relativ_dist        = hist_dist/sum(hist_dist);
nbs_cdf             = cumsum(relativ_dist);


