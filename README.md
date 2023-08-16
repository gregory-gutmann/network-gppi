# gppi-network

gppi-network builds on the [gPPI Version 13.1](https://www.nitrc.org/projects/gppi) Toolbox by McLaren et al. (2013) for task-based experiments and enables the user to apply general PsychoPhysiological Interaction analysis on a network of regions reciprocally. While in the original gPPI the eigenvariate of a seed region is chosen in predicting the activity of different target voxels (often whole-brain), in gppi-network a set of regions can be choosen. There eigenvariates will then be extracted and used as seed- as well as target-region for gPPI analysis. This results in an individual square matrix - a little bit similar to a correlation matrix even though its not a symmetric matrix - that can be used for further analysis. I included a short tutorial based on [one open data](https://openneuro.org/datasets/ds004656/versions/1.0.0) set from Masterdon et al. (2016).

## The idea behind gPPI
Very simplified, gPPI models the time series (t) of a target voxel based on design regressors, the time series of a seed region (eigenvariate of the time series of the voxels included in this region), as well as the interaction between design regressors and seed region. Cofounding regressors like movement parameters can also be factored in. Or in short (see below for practical exp.):

  target(t) = β0 + β1 design(t) + β2 seed(t) + β3 design_seed(t) + nuissance regressors + e(t)         

Of most interest are the values of the β3 estimates as they are an indicator for the strength of the relationship between seed- and target-region controlled for the same external input (unlike the β2 estimates). β3 estimates are large when both regions have similar activity during task (e.g. when picture is shown) and unsimilar activity during control (e.g. when black screen is shown). Similar activity during control will decrease β3 estimates towards zero/nagative values.

For a more detailed explanation see McLaren et al. (2012)


## Tutorial

In this tutorial I used fMRI data from one subject provided by Masterdon et al. (2016). During their experiment they compared the effect of showing high- and low-calorie food as well as controll images early and late in the day. For the tutorial I only analysed the morning session. Given the three conditions 'high', 'low' and 'cont' (for control) the following regressors where used in modelling the respected target time series:

target(t) = β0 + β11 high(t) + β12 low(t) + β13 cont(t) + β2 seed(t) + β31 high_seed(t) + β32 low_seed(t) + β33 cont_seed(t) + e(t)

The defined network used all 246 regions included in the [Brainnetome Atlas](https://atlas.brainnetome.org) developed by Fan et al. (2016). Individual ROI-masks with a sphere of 8 mm radius where created. There were centered around peaks based on standard first-level activity contrasts, in this case high>low calorie food images. The different gPPI parameters were then created for each seed region and in a following step applied to each target region to estimate the beta weights. Similar to activity first-level anaylsis the beta weights can be combined to look at contrasts of interest. In the following I will look mainly at the β31 > β32 contrast or in other words the ppi-contrast for high>low calorie food. 

Additional notes: As nuissance regressors the six rigid-body transformtion parameters where used. The experiment was  split in two sessions which is also not reflected in the shown formula. The data where preprocessed using halfpipe and a first-level analysis was conducted using SPM12. The included region masks were also realigned to fit the dimension and orientation of the bold data.

### Use of tutorial

The tutorial can be easily run, you just need to update the working directory in the main.m and visualization_gppi_mat.m. The functions of gppi-network (found in library) should not need any chance. inits.m sets up all used parameters and gives an explanation of the needed arguments and is included in the main.m script as a function. The main.m script load these parameters and runs the steps of the gppi-network packet. Additionally, visualization_gppi_mat.m is just the code of how I created the images shown here.

The packet and tutorial are programmed for Windows, but you can find an additional library for gppi-network and adapted tutorial-scripts in the folder linux&max that should run on these systems. As a prerequisite you need SPM and some SPM-functions might rely on the Image Processing Toolbox. You just need to replace the lib-folder and use the included tutorial-scripts.

  
### Psychophysiological interaction contrast for high- over low calorie food images 

As a 246x247 heatmap might be a bit unfit for visual inspection I selected a set of seed and target regions containing the 20 most positive or negative contrasts. The seed regions includes among others regions from the prefrontal cortex, inferior temporal gyrus (ITG) and thalamus. The target set includes regions of the precentral gyrus, ITG, fusiform gyrus (FuG) and parahippocampal gyrus. Even though this reflects just one subject the set overlaps with the reported regions from Masterdon et al. (2016). Highly interesting might be the thalamic seed regions given the afferent connection of the thalamus to the neocortex and it's role in visual perception (USrey & Alitto, 2015). Furthermore, right parts of the ITG and left parts of the FuG seem to be prime target regions which makes sense as they are highly assosciated with visual processing e.g. object recognition (Lin et al., 2020; Weiner & Zilles, 2016).

![ppi-hi-over-low](https://github.com/gregory-gutmann/gppi-network/assets/36300365/74078547-44ba-4fb5-8fe0-a02da778536e)


### Psychological or design contrast for high- over low calorie food images 

The following image shows the contrast of β11>β12 meaning the differences in beta-weights between the regular high- and low-calorie condition – without the interaction with the seed time series. In contrast with the ppi-contrast the main difference seem to be between the target region with little variance within them. This makes sense as this contrast reflects a combination of design parameters. But similar to the ppi-contrast most values are positive which fits to the finding of Masterdon et al. (2016) that high-calorie food were associated with greater acitivity the low-calorie food. For a better comparison the same colour ratio is choosen.

![hi-over-low](https://github.com/gregory-gutmann/gppi-network/assets/36300365/aa07588f-5c31-4939-b92d-c176825e5332)

### Physiological contrast

This contrast reflects β2 or the direct relationship between seed and target. In this case I just picked the first 50 regions of the atlas. As expected, the beta weights are way higher when seed and target region is the same. This is not the case for the ppi- or design contrast.

![roi_ev_50](https://github.com/gregory-gutmann/gppi-network/assets/36300365/e1434db2-3ffc-46df-9a64-cd60591615d4)


## Overview of the packet ggpi-network

My packet is heavily based upon the gPPI-Toolbox by McLaren et al. (2012). Mainly, I created a framework around their gPPI-modelling for my intented goal. The following structure gives a simple overview of the included function,their purpose and in which order they are apllied. 

![gppi](https://github.com/gregory-gutmann/gppi-network/assets/36300365/861e6d65-e640-4e89-9306-0ca560499b8d)


### Contact information

For questions and comments I can be reached at gregory.gutmann@fu-berlin.de.

### Literatur
- Fan, L., Li, H., Zhuo, J., Zhang, Y., Wang, J., Chen, L., ... & Jiang, T. (2016). The human brainnetome atlas: a new brain atlas based on connectional architecture. Cerebral cortex, 26(8), 3508-3526.
- Lin, Y. H., Young, I. M., Conner, A. K., Glenn, C. A., Chakraborty, A. R., Nix, C. E., ... & Sughrue, M. E. (2020). Anatomy and white matter connections of the inferior temporal gyrus. World Neurosurgery, 143, e656-e666.
- Masterson, T. D., Kirwan, C. B., Davidson, L. E., & LeCheminant, J. D. (2016). Neural reactivity to visual food stimuli is reduced in some areas of the brain during evening hours compared to morning hours: an fMRI study in women. Brain imaging and behavior, 10(1), 68-78.
- McLaren, D. G., Ries, M. L., Xu, G., & Johnson, S. C. (2012). A generalized form of context-dependent psychophysiological interactions (gPPI): a comparison to standard approaches. Neuroimage, 61(4), 1277-1286.
- Usrey, W. M., & Alitto, H. J. (2015). Visual functions of the thalamus. Annual review of vision science, 1, 351-371.
- Weiner, K. S., & Zilles, K. (2016). The anatomical and functional specialization of the fusiform gyrus. Neuropsychologia, 83, 48-62.
