# gppi-network

gppi-network builds on the [gPPI Version 13.1](https://www.nitrc.org/projects/gppi) Toolbox by McLaren et al. (2013) for task-based experiments and enables the user to apply general PsychoPhysiological Interaction analysis on a network of regions reciprocally. While in the original gPPI the eigenvariate of a seed region is chosen in predicting the activity of different target voxels (often whole-brain), in gppi-network a set of regions can be choosen. There eigenvariates will then be extracted and used as seed- as well as target-region for gPPI analysis. This results in an individual square matrix - a little bit similar to a correlation matrix even though its not a symmetric matrix - that can be used for further analysis. I included a short tutorial based on [one open data](https://openneuro.org/datasets/ds004656/versions/1.0.0) set from Masterdon et al. (2016).

## The idea behind gPPI
Very simplified, gPPI models the time series (t) of a target voxel based on design regressors, the time series of a seed region (eigenvariate of the time series of the voxels included in this region), as well as the interaction between design regressors and seed region. Cofounding regressors like movement parameters can also be factored in. Or in short (see below for practical exp.):

  target(t) = β0 + β1 design(t) + β2 seed(t) + β3 design_seed(t) + nuissance regressors + e(t)         

Of most interest are the values of the β3 estimates as they are an indicator for the strength of the relationship between seed- and target-region controlled for the same external input (unlike the β2 estimates). β3 estimates are large when both regions have similar activity during task (e.g. when picture is shown) and unsimilar activity during control (e.g. when black screen is shown). Similar activity during control will decrease β3 estimates towards zero/nagative values.

For a more detailed explanation see McLaren et al. (2013)


## Tutorial

In this tutorial I used fMRI data from one subject provided by Masterdon et al. (2016). During their experiment they compared the effect of showing high- and low-calorie food as well as controll images early and late in the day. For the tutorial I only analysed the morning session.  

## Overview of the packet

![roi_ev_50](https://github.com/gregory-gutmann/gppi-network/assets/36300365/e1434db2-3ffc-46df-9a64-cd60591615d4)

![roi_ev](https://github.com/gregory-gutmann/gppi-network/assets/36300365/9eade133-0cbd-434e-8a37-575830ef5761)



![hi-over-low](https://github.com/gregory-gutmann/gppi-network/assets/36300365/aa07588f-5c31-4939-b92d-c176825e5332)



![ppi-hi-over-low](https://github.com/gregory-gutmann/gppi-network/assets/36300365/74078547-44ba-4fb5-8fe0-a02da778536e)





For the tutorial the following model is applied

### Literatur
Masterson, T. D., Kirwan, C. B., Davidson, L. E., & LeCheminant, J. D. (2016). Neural reactivity to visual food stimuli is reduced in some areas of the brain during evening hours compared to morning hours: an fMRI study in women. Brain imaging and behavior, 10(1), 68-78.
McLaren, D. G., Ries, M. L., Xu, G., & Johnson, S. C. (2012). A generalized form of context-dependent psychophysiological interactions (gPPI): a comparison to standard approaches. Neuroimage, 61(4), 1277-1286.
