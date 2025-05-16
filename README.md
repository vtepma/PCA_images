# PCA_images
R script for clustering EDS element maps (or other multi-channel images) using principal components.  Email moorelr@vt.edu for questions or comments.

250516 update: added "background correction.R" script which should be able to remove background noise from EDS or WDS maps.  This is done by plotting the BSE image against the X-ray count signal, where the background should be correlated with the BSE brightness.  In theory, this should work for removing differences in count rate related to variations in the mean atomic number of the material being analyzed, but it will not correct for X-ray interferences.  I have not tested this script thoroughly, but I think it is worth preserving and will be useful in the future.  Also, it seems to work better if "grainy" images are smoothed first.

To use:
1) Paste in path to input directory with TIFF images and output directory containing "cluster image files.txt" removing forward slashes as needed.
2) Make sure there that the "cluster image files.txt" file is formatted correctly and located in the desired output directory.  It should just be a tab-separated file with the first column being the file name of each tiff image and the element represented by the image.  This file controls which elements are used for clustering.
3) Run things section-by section to make sure the output looks right.
4) After the PC images are saved, that's when I would usually manually make an RGB-formatted PC image with ImageJ
5) Note that the K-means clustering uses PCs 1 through 5 -- this might be dumb.  Maybe better to just use the data from the images?  I don't remember why I decided it was better to do this.
6) Scree plot for K-means clustering takes forever.  Max clusters is 10 which is usually enough without being too much.
7) At the end of the K-means section, there is an opportunity to set the number of clusters ("n_clust" catriable) and then remove bullshit clusters by combining them with other clusters (e.g. "clusters[which(clusters %in% c(8))] <- 2")
8) Finally, I prefer to view the clusters in ImageJ and "despeckle" them.

Change notes:

250414:
- Changed folders to feature example output using example input data.
- Removed rgl and rgdal packages, which are no longer used and depreciated.
- added optional functionality from beepr package
