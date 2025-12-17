# network-gppi

network-gppi builds on the [gPPI Version 13.1](https://www.nitrc.org/projects/gppi) Toolbox by McLaren et al. (2013) for task-based experiments and enables the user to apply general PsychoPhysiological Interaction analysis on a network of defined regions, i.e., model task-based connectivity between a high number of regions. While in the original gPPI the eigenvariate of a seed region is chosen in predicting the activity of different target voxels (often brain wide), in network-gppi, a set of regions can be chosen. The eigenvariates will then be extracted and used as seed as well as target regions for subsequent gPPI analysis with all other regions. This results in a connectivity matrix for every participant, which can be used for further analyses. For more information about network-gppi, please see its initial introduction in Gutmann et al. (in prep). 

Next to the network-gppi library, two tutorials are included. The first tutorial (A) describes how network-gppi can be applied to compute first-level connectivity matrices using [an open dataset from Masterdon et al. (2016)](https://openneuro.org/datasets/ds004656/versions/1.0.0). The second tutorial (B) contains an exemplary second-level analyses pipeline using network-based statistics (NBS, Zalesky et al., 2010) as well as further instruction of how to visualise brain connectivities using BrainNet Viewer (Xia et al., 2013). It focuses on a two-sample t-test, but additional information is provided for one-sample t-tests and correlations. For this tutorial, connectivity datasets were generated reflecting the group difference between depressed patients and healthy controls described in my own study (Gutmann et al., in prep).

## Contact information

For questions and comments, I can be reached at [gregory.gutmann@fu-berlin.de](mailto:gregory.gutmann@fu-berlin.de).

## The idea behind gPPI
In simplified terms, gPPI models the time series (t) of a target voxel based on design regressors, the time series of the seed region (eigenvariates of the time series of the voxels included in this region), as well as the interactions between design regressors and the seed region. Confounding regressors like movement parameters can also be factored in. In short (see below for practical exp.):

  target(t) = β0 + β1 design(t) + β2 seed(t) + β3 design_seed(t) + nuissance regressors + e(t)         

Of most interest are the values of the β3 estimates as they are an indicator for the strength of the relationship between seed and target regions controlled for the same external input (unlike the β2 estimates).

For a more detailed explanation, see McLaren et al. (2012).


# Tutorial A: First-level Analyses

In this tutorial, I used fMRI data from one subject provided by Masterdon et al. (2016). During their experiment, they compared the effects of showing high- and low-calorie food as well as control images during a morning session and an evening session. For the tutorial, I only analysed the morning session. Given the three conditions: 'high', 'low', and 'cont' (for control), the following regressors were used in predicting the target time series:

target(t) = β0 + β11 high(t) + β12 low(t) + β13 cont(t) + β2 seed(t) + β31 high_seed(t) + β32 low_seed(t) + β33 cont_seed(t) + e(t)

The defined network used all 246 regions included in the Brainnetome Atlas developed by Fan et al. (2016). Individual ROI-masks with a sphere of 8 mm radius were created. They were centered around peaks based on standard first level activity contrasts, which in this were case high>low calorie food images. However, the script also describes how the whole ROI can be used, which I normally do when applying the Brainnetome Atlas (Gutmann et al., in print). The different gPPI parameters were then created for each seed region, and in a following step, applied to each target region to estimate the beta weights. Similar to first level activity analysis, the beta weights can be combined to look at contrasts of interest. In the following, I will look mainly at the β31 > β32 contrast, or in other words, the ppi-contrast for high>low calorie food.

Additional notes: As nuisance regressors, the six rigid-body transformation parameters were used. The experiment was split in two sessions, which is not reflected in the shown formula. The data was preprocessed using HALFpipe. The included region masks were also realigned to fit the dimension and orientation of the bold data.

### Use of tutorial

An example of how to use the network-gppi toolbox is provided in the script “main_first_level.m”. It contains further information and can be used as a template for other network-gppi analyses. Additionally, the script “visualization_gppi_mat.m” provides the code for the images shown below. 

The tutorial is located in the “tutorial_fst_level” folder. Of course, you also need the gppi-network toolbox (located in “lib”) as well as SPM. Also, some SPM-functions might rely on the Image Processing Toolbox.

  
### Psychophysiological interaction contrast for high- over low-calorie food images (ppi-contrast)

As a 246x247 heatmap might be unfit for visual inspection, I selected a set of seed and target regions containing the 30 most positive or negative contrasts. The seed regions include multiple ROIs from the prefrontal cortex, parietal cortex and the amygdala. The target set includes multiple regions of the occipital cortex and cuneus. The most extreme values seem to be mostly positive, meaning more positive connections for high-calorie food in comparison to low-calorie food.

![ppi_hi_over_low](https://github.com/gregory-gutmann/network-gppi/assets/36300365/a57f8f14-e6f5-4659-9484-cc2c89bc8df5)





### Psychological contrast for high- over low-calorie food images

The following image shows the contrast of β11>β12, meaning the differences in beta-weights between the regular high- and low-calorie food condition. Most of the variance seems to be explained by the different target regions with less influence of the seed regions. This makes sense as this contrast in comparison to ppi-contrast only reflects a combination of design parameters (β11 and β12). The ppi-contrast on the other hand reflects the interaction between design parameters and the seed time series (β31 and β32). Most values are positive, which is in line with the finding of Masterdon et al. (2016) that high-calorie food images were associated with greater activity than low-calorie food images. For a better comparison, the same colour ratio was chosen that was also used for the PPI-contrast.

![hi_over_low](https://github.com/gregory-gutmann/network-gppi/assets/36300365/b913f127-677c-40d4-baf5-ffad45ac8a70)




### Physiological contrast

This contrast reflects β2 or the direct relationship between the seed and the target time series. In this case, I selected the first 50 regions of the atlas. As expected, the beta weights are much higher when the seed and the target region are the same. This is not the case for the ppi- or design contrast.

![roi_ev](https://github.com/gregory-gutmann/network-gppi/assets/36300365/97bbd3e4-8042-4216-b94b-f23c32bf8802)





## Overview of the packet ggpi-network

My packet is heavily based on the gPPI-Toolbox by McLaren et al. (2012). Mainly, I created a framework around their gPPI-modelling for my intended goal. The following structure gives a simple overview of the included function, their purpose, and in which order they are applied. Note, if many connections are included, the resulting data can become quite large. Because of this, it might be important to delete intermediary files. 

![gppi-structure](https://github.com/gregory-gutmann/gppi-network/assets/36300365/7e13b38f-a22f-4781-abdd-4526988fa011)





# Tutorial B: Second-level analyses

As the second-level analyses of the network-gppi connectivity data can be rather challenging, this tutorial was added to present a potential pipeline, which can be hopefully used as a stepping stone for new analyses. The approach used here is based on my work in Gutmann et al. (in prep) and uses network-based statistics (NBS) to evaluate effects and focuses on central hubs in its interpretations. Instead of examining singular links, NBS statistically evaluates the size of components, i.e., networks of regions which are linked by significant connections (p < .001), through permutation testing (for more information, see Zalesky et al., 2010). The simulated data contains two groups with 40 subjects each. They are based on the mean and standard deviation of the depressed group and healthy control group I compared in Gutmann et al. (in prep). In this study, I used data from a Monetary Incentive Delay Task to analyse anhedonia-related network alterations in patients with Major Depressive Disorder. While the tutorial focuses on the group comparison (two-sample t-tests), it also contains further instruction to analyse task effects (one-sample t-tests) as well as correlations with external variables. The simulation process was also restricted so that the generated data did not deviate too much from the original data and the results here are quite reflective of the original difference.

Evaluated using NBS, the group difference is highly significant. The difference might be less distorted by other covariates, and therefore, unnaturally clear. For the original difference between 99 depressed patients and 28 healthy controls, only a trend was observed. However, the connectivity structure is quite similar. The following image shows all surviving connections visualised with the BrainNet Viewer toolbox (see below for more information about the toolbox). Nodes are color sorted to different networks based on the atlas from Schaefer et al. (2018). 

![all_connections](https://github.com/user-attachments/assets/6558b462-607c-498f-b29d-dd41c960ce09)






As can be seen in this image, the data is highly complex. To simplify it, I decided to focus more on the most central hubs, i.e. nodes which are highly connected within this network. The next image shows only connections between nodes which have five or more surviving connections.

![central_hubs](https://github.com/user-attachments/assets/106298ad-9ac7-4fb6-b984-a3e6599f2fd8)






When trying to interpret the data, it might also be very helpful to zoom in on specific nodes that seem to be relevant. The shared script also creates a file for every central node that can be viewed with the BrainNet Viewer. Shown here are all surviving connections of the left dorsal caudate, which was one of the most connected nodes and is a highly relevant part of the reward network.

![left_caudate](https://github.com/user-attachments/assets/22ecbfe3-5ad7-4b49-a80b-10ea9e5d4efb)






## BrainNet Viewer

To visualise the data with BrainNet Viewer, the [toolbox must be of course downloaded](https://www.nitrc.org/projects/bnv) and its path added in Matlab . To open BrainNet Viewer, type BrainNet into Matlab. Besides the edge-files, which contain information about the relevant connections and are created with the ‘tutorial_scd_level.m’ script, all files you need are within the brainnetview folder (surface, node, options, colormap). 

If you open a new file (File>Load File), you can load in the surface, node, and edge file in the first window. The option file can then be included in the next window. If the colormap is not automatically included, you can load it via Option>Node>Color>More>Load Custom Color. It might be very worthwhile to alter the options to the particular data. For more information about BrainNet, you can also refer also to this manual. [https://www.nitrc.org/docman/view.php/504/77994/BrainNet Viewer Manual 1.61.pdf](https://www.nitrc.org/docman/view.php/504/77994/BrainNet%20Viewer%20Manual%201.61.pdf)

## High Performance Cluster

To avoid daylong run times, I analysed the data for my study using a High Performance Cluster. This is particularly suitable when investigating full-brain connectivity in a large number of studies. However, this can be quite tricky—especially in the set-up—and requires some experience. Should you be interested, feel free to contact me at the aforementioned mail-address.


## Literature
- Fan, L., Li, H., Zhuo, J., Zhang, Y., Wang, J., Chen, L., ... & Jiang, T. (2016). The human brainnetome atlas: a new brain atlas based on connectional architecture. Cerebral cortex, 26(8), 3508-3526.
- Gutmann, G., Golde, S., Schwefel, M., Heissel, A., & Heinzel, S. (in prep.). Did I win? Assessing anhedonia related whole-brain connectivity changes in depression using the newly developed toolbox network-gppi
- McLaren, D. G., Ries, M. L., Xu, G., & Johnson, S. C. (2012). A generalized form of context-dependent psychophysiological interactions (gPPI): a comparison to standard approaches. Neuroimage, 61(4), 1277-1286.
- Masterson, T. D., Kirwan, C. B., Davidson, L. E., & LeCheminant, J. D. (2016). Neural reactivity to visual food stimuli is reduced in some areas of the brain during evening hours compared to morning hours: an fMRI study in women. Brain imaging and behavior, 10(1), 68-78.
- Schaefer, A., Kong, R., Gordon, E. M., Laumann, T. O., Zuo, X. N., Holmes, A. J., . . . Yeo, B. T. T. (2018). Local-Global Parcellation of the Human Cerebral Cortex from Intrinsic Functional Connectivity MRI. *Cereb Cortex*, *28*(9), 3095-3114.
- Xia, M., Wang, J., & He, Y. (2013). BrainNet Viewer: a network visualization tool for human brain connectomics. *PloS one*, *8*(7), e68910.
Zalesky, A., Fornito, A., & Bullmore, E. T. (2010). Network-based statistic: identifying differences in brain networks. *Neuroimage*, *53*(4), 1197-1207.

