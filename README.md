# PCA_images
R script for clustering EDS element maps (or other multi-channel images) using principal components.  Email moorelr@vt.edu for questions or comments.

Note: I think I might have a problem soon because of one of the dependencies becoming depreciated.  That's "future me's" problem!

To use:
1) Paste in path to input directory with TIFF images and output directory containing "cluster image files.txt" removing forward slashes as needed.
2) Make sure there that the "cluster image files.txt" file is formatted correctly.  It should just be a tab-separated file with the first column being the file name of each tiff image and the element represented by the image.  This file controls which elements are used for clustering.
3) Run things section-by section to make sure the output looks right.
4) After the PC images are saved, that's when I would usually manually make an RGB-formatted PC image with ImageJ
5) Note that the K-means clustering uses PCs 1 through 5 -- this might be dumb.  Maybe better to just use the data from the images?  I don't remember why I decided it was better to do this.
6) Scree plot for K-means clustering takes forever.  Max clusters is 10 which is usually enough without being too much.
7) At the end of the K-means section, there is an opportunity to set the number of clusters ("n_clust" catriable) and then remove bullshit clusters by combining them with other clusters (e.g. "clusters[which(clusters %in% c(8))] <- 2")
8) Finally, I prefer to view the clusters in ImageJ and "despeckle" them.
