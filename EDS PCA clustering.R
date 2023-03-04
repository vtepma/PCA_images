# Copyright Lowell R. Moore 2023 -- MIT License


# TODO
#   - 

# Note: this example code isn't going to work by running the whole script, and
#   a little manual user input is required.  More details in the README.

# -----------------------------------------------
# Initialization
# -----------------------------------------------

library("raster") # for the "raster()" function
library("rgdal")  # used to make the "raster()" function work with
#   different standard image  types

# Function to flag points occurring within a polygon
locate_poly <- function(x_points, y_points, n_poly){
  print(paste("Click", n_poly, "points to create polygon..."))
  points_select <- locator(n = n_poly)
  
  xs_line <- points_select$x
  ys_line <- points_select$y
  center_poly <- c(mean(xs_line), mean(ys_line))
  points(center_poly[1], center_poly[2], pch = 21, bg = "darkblue")
  
  xs_line <- c(xs_line, xs_line[1])
  ys_line <- c(ys_line, ys_line[1])
  lines(xs_line, ys_line, lty = 2, col = "red")
  
  ms_line <- numeric(0)
  bs_line <- numeric(0)
  flag <- 1:length(x_points)
  for(i in 1:(length(xs_line)-1)){
    # Debug : i <- 1
    ms_line[i] <- (ys_line[i+1]-ys_line[i])/(xs_line[i+1]-xs_line[i])
    bs_line[i] <- ys_line[i] - (ms_line[i]*xs_line[i])
    center_is_below <- center_poly[2] < (ms_line[i]*center_poly[1])+bs_line[i]
    if(center_is_below){
      flag_i <- which(y_points < (ms_line[i]*x_points)+bs_line[i])
    }
    if(!center_is_below){
      flag_i <- which(y_points > (ms_line[i]*x_points)+bs_line[i])
    }
    
    print(paste(
      "i =", i, "ms_line =", round(ms_line[i], 2), " -- bs_line =", round(bs_line[i], 2)
      , " -- center_is_below =", center_is_below
      , " -- flag = ", length(flag), "points"
      , " -- flag_i = ", length(flag_i), "points"
      , sep = " "))
    
    flag <- intersect(flag, flag_i)
  }
  
  return(flag)
}

# set up directory
image_dir <- "EDS data"
output_dir <- "example images"

# preview image of one image channel
image_path <- paste(image_dir, "Map_002_CountMap_Ca-K.tif", sep = "/")
eds_map <- raster(image_path, band = 1)
plot(eds_map, col = hcl.colors(100, palette = "Hawaii"))
# hcl.pals()  #  Optional list of available color palettes


# -----------------------------------------------
# Retrieve flagged pixels over image area
# -----------------------------------------------

# Flagged pixels are identified across several RGB images

# Color channels
eds_Al <- raster(paste(image_dir, "Map_002_CountMap_Al-K.tif", sep = "/"))[,]
eds_Ca <- raster(paste(image_dir, "Map_002_CountMap_Ca-K.tif", sep = "/"))[,]
eds_C <- raster(paste(image_dir, "Map_002_CountMap_C-K.tif", sep = "/"))[,]
eds_Fe <- raster(paste(image_dir, "Map_002_CountMap_Fe-K.tif", sep = "/"))[,]
eds_K <- raster(paste(image_dir, "Map_002_CountMap_K-K.tif", sep = "/"))[,]
eds_Mg <- raster(paste(image_dir, "Map_002_CountMap_Mg-K.tif", sep = "/"))[,]
eds_Na <- raster(paste(image_dir, "Map_002_CountMap_Na-K.tif", sep = "/"))[,]
eds_O <- raster(paste(image_dir, "Map_002_CountMap_O-K.tif", sep = "/"))[,]
eds_Si <- raster(paste(image_dir, "Map_002_CountMap_Si-K.tif", sep = "/"))[,]
eds_Ti <- raster(paste(image_dir, "Map_002_CountMap_Ti-K.tif", sep = "/"))[,]

image_data <- cbind(eds_Al
                    , eds_Ca
                    , eds_C
                    , eds_Fe
                    , eds_K
                    , eds_Mg
                    , eds_Na
                    , eds_O
                    , eds_Si
                    , eds_Ti
                    )

# -------------------------------------------
# PCA and plot figures
# -------------------------------------------

# Calculate principal components
pc_result <- prcomp(image_data, center = TRUE, scale = TRUE)

# Scree plot
output_path <- paste(output_dir, "Stack (RGB) PCA screeplot.bmp", sep = "/")
bmp(file = output_path
    , width = 512, height = 512
)
screeplot(pc_result, type = "lines"
          #, log = "y"
          )
dev.off()

# Save PC images
# Note: These can be opened in ImageJ as "text images" to create an RGB image
#   of the PCs.
save_PCs <- c(1, 2, 3)
for(i in save_PCs){
  eds_map[] <- pc_result$x[,i]
  output_path <- paste(output_dir, "/PC", i, " map.csv", sep = "")
  write.csv(file = output_path, x = as.matrix(eds_map)
            , row.names = FALSE, quote = FALSE)
}

# Scatterplot of PCs 1 and 2
output_path <- paste(output_dir, "Stack (RGB) PCA.bmp", sep = "/")
bmp(file = output_path
    , width = 512, height = 512
    #, useDingbats = FALSE
)
plot(pc_result$x, pch = 16
     , col = densCols(pc_result$x[,1], pc_result$x[,2], colramp = colorRampPalette(hcl.colors(12, palette = "Rocket")))
     #, col = rgb(xs/255, ys/255, zs/255) 
)
dev.off()

# example biplot (not useful for image segmentation with many pixels)
if(FALSE){
  biplot(pc_result$x[flag,1], pc_result$x[flag,2]
         #, col = densCols(pc_result$x[,1], pc_result$x[,2], colramp = colorRampPalette(hcl.colors(12, palette = "Rocket")))
         , type = "points"
  )
}


# ----------------------------------------------------------
# manual clustering
# ----------------------------------------------------------

# Note: a little bit of manual user input is required in this section, where
#   clusters are identified using a downsampled plot of PCs 1 and 2, and the "locate" function, which
#   is called by the "locate_poly" function.

n_points <- length(pc_result$x[,1])
flag <- sample(1:n_points, size = 0.05*n_points, replace = FALSE)
plot(pc_result$x[flag,1], pc_result$x[flag,2], pch = 16
     , col = densCols(pc_result$x[flag,1], pc_result$x[flag,2], colramp = colorRampPalette(hcl.colors(12, palette = "Rocket")))
     #, col = rgb(xs/255, ys/255, zs/255) 
)

# Clusters are identified one-by-one and saved under a separate variable.
# Note: the locate function isn't very reliable, so click polygon vertices slowly
#   to make sure R doesn't crash and the polygon is registered correctly.
clust_1 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)
clust_2 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)
clust_3 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)
clust_4 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)
clust_5 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)
clust_6 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)
clust_7 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)
clust_8 <- locate_poly(pc_result$x[,1], pc_result$x[,2], n_poly = 5)

if(FALSE){
  # This is used to hold the shape of the map area, and it can be plotted as a
  #   visual aid if necessary
  eds_map <- raster(image_path, band = 1)
  plot(eds_map, col = hcl.colors(100, palette = "Rocket"))
  # hcl.pals()
}

# Save preview image of clusters
output_path <- paste(output_dir, "Stack (RGB) clusters.bmp", sep = "/")
bmp(file = output_path
    , width = round(1.2*ncol(eds_map)), height = round(1.2*nrow(eds_map))
    #, useDingbats = FALSE
)
# Note: some pixels are clustered in duplicate by overlapping polygons, and these
#   are overwritten according to the order in which cluster values are assigned
#   to the image
eds_map[] <- 0
eds_map[clust_1] <- 1
eds_map[clust_2] <- 2
eds_map[clust_3] <- 3
eds_map[clust_4] <- 4
eds_map[clust_5] <- 5
eds_map[clust_6] <- 6
eds_map[clust_7] <- 7
eds_map[clust_8] <- 8
plot(eds_map, col = hcl.colors(9, palette = "Hawaii"))
dev.off()

# Save clusters to CSV
# Note: again, this can be opened in ImageJ as a "text image" for postprocessing
output_path <- paste(output_dir, "Stack (RGB) clusters.csv", sep = "/")
write.csv(file = output_path, x = as.matrix(eds_map)
          , row.names = FALSE, quote = FALSE)

