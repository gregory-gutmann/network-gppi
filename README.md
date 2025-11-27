# network-gppi

network-gppi builds on the [gPPI Version 13.1](https://www.nitrc.org/projects/gppi) Toolbox by McLaren et al. (2013) for task-based experiments and enables the user to apply general PsychoPhysiological Interaction analysis on a network of defined regions i.e., model task-based connectivity between a high number of regions. While in the original gPPI the eigenvariate of a seed region is chosen in predicting the activity of different target voxels (often brain wide), in network-gppi a set of regions can be chosen. The eigenvariates will then be extracted and used as seed as well as target regions for subsequent gPPI analysis with all other regions. This results in a connectivity matrix for every participant, which can be used for further analyses. For more information about network-gppi, please see its initial introduction in Gutmann et al. (in prep). 

Next to the network-gppi library, two tutorials are here included. The first tutorial (A) describes how network-gppi can be applied to compute first-level connectivity matrices using [an open dataset from Masterdon et al. (2016)](https://openneuro.org/datasets/ds004656/versions/1.0.0). The second tutorial (B) contains an exemplary second-level analyses pipeline using network-based statistics (NBS, Zalesky et al., 2010) as well as further instruction of how to visualise brain connectivities using BrainNet Viewer (Xia et al., 2013). It focuses on a two-sample t-test, but additional informations are provided for one-sample t-tests and correlations. For this tutorial, connectivity datasets were generated reflecting the group difference between depressed patients and healthy controls describe in my own study (Gutmann et al., in prep).

## Contact information

For questions and comments I can be reached at [gregory.gutmann@fu-berlin.de](mailto:gregory.gutmann@fu-berlin.de).

## The idea behind gPPI
Very simplified, gPPI models the time series (t) of a target voxel based on design regressors, the time series of the seed region (eigenvariates of the time series of the voxels included in this region), as well as the interactions between design regressors and the seed region. Confounding regressors like movement parameters can also be factored in. In short (see below for practical exp.):

  target(t) = β0 + β1 design(t) + β2 seed(t) + β3 design_seed(t) + nuissance regressors + e(t)         

Of most interest are the values of the β3 estimates as they are an indicator for the strength of the relationship between seed and target regions controlled for the same external input (unlike the β2 estimates).

For a more detailed explanation see McLaren et al. (2012).


# Tutorial A: First-level Analyses

In this tutorial I used fMRI data from one subject provided by Masterdon et al. (2016). During their experiment, they compared the effects of showing high- and low-calorie food as well as control images during a morning session and an evening session. For the tutorial, I only analysed the morning session. Given the three conditions 'high', 'low', and 'cont' (for control), the following regressors were used in predicting the target time series:

target(t) = β0 + β11 high(t) + β12 low(t) + β13 cont(t) + β2 seed(t) + β31 high_seed(t) + β32 low_seed(t) + β33 cont_seed(t) + e(t)

The defined network used all 246 regions included in the Brainnetome Atlas developed by Fan et al. (2016). Individual ROI-masks with a sphere of 8 mm radius were created. They were centered around peaks based on standard first level activity contrasts, in this case high>low calorie food images. However, the script also describes how the whole ROI can be used which I do normally when applying the Brainnetome Atlas (Gutmann et al., in print). The different gPPI parameters were then created for each seed region and in a following step applied to each target region to estimate the beta weights. Similar to first level activity analysis the beta weights can be combined to look at contrasts of interest. In the following I will look mainly at the β31 > β32 contrast or in other words the ppi-contrast for high>low calorie food.

Additional notes: As nuisance regressors the six rigid-body transformation parameters were used. The experiment was split in two sessions, which is also not reflected in the shown formula. The data were preprocessed using HALFpipe. The included region masks were also realigned to fit the dimension and orientation of the bold data.

### Use of tutorial

An example of how to use the network-gppi toolbox is provided in the script “main_first_level.m”. It contains many further information and can be used as a template for other network-gppi analyses. Additional, the script “visualization_gppi_mat.m” provides the code for the images shown below. 

The tutorial is located in the “tutorial_fst_level” folder. Of course, you also need the gppi-network toolbox (located in “lib”) as well as SPM. Also, some SPM-functions might rely on the Image Processing Toolbox.

  
### Psychophysiological interaction contrast for high- over low-calorie food images (ppi-contrast)

As a 246x247 heatmap might be unfit for visual inspection, I selected a set of seed and target regions containing the 30 most positive or negative contrasts. The seed regions include multiple ROIs from the prefrontal cortex, parietal cortex and the amygdala. The target set includes multiple regions of the occipital cortex and cuneus. The most extreme values seem to be mostly positive meaning more positive connections for high-calorie food in comparison to low-calorie food.

![ppi_hi_over_low](https://github.com/gregory-gutmann/network-gppi/assets/36300365/a57f8f14-e6f5-4659-9484-cc2c89bc8df5)





### Psychological contrast for high- over low-calorie food images

The following image shows the contrast of β11>β12 meaning the differences in beta-weights between the regular high- and low-calorie food condition. Most of the variance seem to be explained by the different target regions with less influence of the seed regions. This makes sense as this contrast in comparison to ppi-contrast only reflects a combination of design parameters (β11 and β12). The ppi-contrast on the other hand reflects the interaction between design parameters and the seed time series (β31 and β32). Most values are positive which is in line with the finding of Masterdon et al. (2016) that high-calorie food images were associated with greater activity than low-calorie food images. For a better comparison the same colour ratio was chosen that was also used for the PPI-contrast.

![hi_over_low](https://github.com/gregory-gutmann/network-gppi/assets/36300365/b913f127-677c-40d4-baf5-ffad45ac8a70)




### Physiological contrast

This contrast reflects β2 or the direct relationship between the seed and the target time series. In this case, I selected the first 50 regions of the atlas. As expected, the beta weights are much higher when the seed and the target region are the same. This is not the case for the ppi- or design contrast.

![roi_ev](https://github.com/gregory-gutmann/network-gppi/assets/36300365/97bbd3e4-8042-4216-b94b-f23c32bf8802)





## Overview of the packet ggpi-network

My packet is heavily based on the gPPI-Toolbox by McLaren et al. (2012). Mainly, I created a framework around their gPPI-modelling for my intended goal. The following structure gives a simple overview of the included function, their purpose and in which order they are applied. Also, if many connections are included, the resulting data can become quite large. Because of this, it might be important to delete intermediary files. 

![gppi-structure](https://github.com/gregory-gutmann/gppi-network/assets/36300365/7e13b38f-a22f-4781-abdd-4526988fa011)




### Literatur
- Fan, L., Li, H., Zhuo, J., Zhang, Y., Wang, J., Chen, L., ... & Jiang, T. (2016). The human brainnetome atlas: a new brain atlas based on connectional architecture. Cerebral cortex, 26(8), 3508-3526.
- Masterson, T. D., Kirwan, C. B., Davidson, L. E., & LeCheminant, J. D. (2016). Neural reactivity to visual food stimuli is reduced in some areas of the brain during evening hours compared to morning hours: an fMRI study in women. Brain imaging and behavior, 10(1), 68-78.
- McLaren, D. G., Ries, M. L., Xu, G., & Johnson, S. C. (2012). A generalized form of context-dependent psychophysiological interactions (gPPI): a comparison to standard approaches. Neuroimage, 61(4), 1277-1286.

