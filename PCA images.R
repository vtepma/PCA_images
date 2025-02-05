
# Note: this example code isn't going to work by running the whole script, and
#   a little manual user input is required.  More details in the README.

# -----------------------------------------------
# Initialization
# -----------------------------------------------

library("raster") # for the "raster()" function
library("rgdal")  # used to make the "raster()" function work with
#   different standard image  types
library("rgl")    # for 3D exploratory scatter plot

# Set up image directory
image_dir <- ""
output_dir <- ""
cluster_images <- read.table(
    paste(output_dir, "cluster image files.txt", sep = "/")
      , stringsAsFactors = FALSE, sep = "\t", header = TRUE
  )

# preview image of one image channel
image_path <- paste(image_dir, cluster_images$File[1], sep = "/")
eds_map <- raster(image_path, band = 1)
plot(eds_map, col = hcl.colors(100, palette = "Hawaii"))
# hcl.pals()


# -----------------------------------------------
# Retrieve flagged pixels over image area
# -----------------------------------------------

# Flagged pixels are identified across several RGB images

# Color channels
image_data <- raster(paste(image_dir, cluster_images$File[1], sep = "/"))[,]
for(i in 2:nrow(cluster_images)){
  print(paste("Loading image", i, "of", nrow(cluster_images), "--", cluster_images$File[i]))
  image_data <- cbind(image_data, raster(paste(image_dir, cluster_images$File[i], sep = "/"))[,])
}
colnames(image_data) <- cluster_images$Element

# ----------------------------------------------------------
# PCA calculations
# ----------------------------------------------------------

pc_result <- prcomp(image_data, center = TRUE, scale = TRUE)

output_path <- paste(output_dir, "Stack (RGB) PCA screeplot.bmp", sep = "/")
bmp(file = output_path
    , width = 512, height = 512
)
screeplot(pc_result, type = "lines")
dev.off()

# PC Plots
output_path <- paste(output_dir, "PC_plots.pdf", sep = "/")
pdf(output_path, width = 11, height = 8.5, useDingbats = FALSE)
par(mfrow = c(2, 3))
arrow_scale <- 4
# PC1 vs PCi
for(i in 2:6){
  # i <- 2
  print(paste("i =", i))
  pc_x <- 1; pc_y <- i
  flag_rows <- sample(x = i:nrow(image_data), size = 1000, replace = FALSE)
  plot(pc_result$x[flag_rows,c(pc_x, pc_y)]
       #, xlim = c(-12, 5)
       , pch = 16
       , col = densCols(pc_result$x[flag_rows,pc_x], pc_result$x[flag_rows,pc_y], colramp = colorRampPalette(hcl.colors(12, palette = "Rocket")))
  )
  arrows(x0 = 0, x1 = pc_result$rotation[,pc_x]*arrow_scale 
         , y0 = 0, y1 = pc_result$rotation[,pc_y]*arrow_scale 
         , col = "red" 
         , length = 0.08 
         , lwd = 2
         , angle = 30
  )
  text(x = pc_result$rotation[,pc_x]*arrow_scale
       , y = pc_result$rotation[,pc_y]*arrow_scale
       , labels = row.names(pc_result$rotation)
       , cex = 0.8
       #, font = 2
       , col = "darkblue"
       , adj = c(0, 0.5)
  )
}
# PC2 vs PC3 (to help interpret RGB image)
{
  # i <- 2
  pc_x <- 2; pc_y <- 3
  flag_rows <- sample(x = i:nrow(image_data), size = 1000, replace = FALSE)
  plot(pc_result$x[flag_rows,c(pc_x, pc_y)]
       #, xlim = c(-12, 5)
       , pch = 16
       , col = densCols(pc_result$x[flag_rows,pc_x], pc_result$x[flag_rows,pc_y], colramp = colorRampPalette(hcl.colors(12, palette = "Rocket")))
  )
  arrows(x0 = 0, x1 = pc_result$rotation[,pc_x]*arrow_scale 
         , y0 = 0, y1 = pc_result$rotation[,pc_y]*arrow_scale 
         , col = "red" 
         , length = 0.08 
         , lwd = 2
         , angle = 30
  )
  text(x = pc_result$rotation[,pc_x]*arrow_scale
       , y = pc_result$rotation[,pc_y]*arrow_scale
       , labels = row.names(pc_result$rotation)
       , cex = 0.8
       #, font = 2
       , col = "darkblue"
       , adj = c(0, 0.5)
  )
}
dev.off()
par(mfrow = c(1, 1))


#PC images
for(i in 1:ncol(pc_result$x)){
  print(paste("Saving PC", i, "image..."))
  eds_map[] <- pc_result$x[,i]
  output_path <- paste(output_dir, "/PC", i, " map.csv", sep = "")
  write.csv(file = output_path, x = as.matrix(eds_map)
            , row.names = FALSE, quote = FALSE)
}


# ----------------------------------------------------------
# K-means clustering
# ----------------------------------------------------------


# Normalize dataset
z <- pc_result$x[,1:5]
m <- apply(z, 2, mean)
s <- apply(z, 2, sd)
z <- scale(z, m, s)

# Scree plot
wss <- numeric(0)
max_clust <- 10
for(i in 2:max_clust){
  print(i)
  wss[i] <- sum(kmeans(z, centers = i
                       , nstart = 3
                       , algorithm = "Hartigan-Wong"
                       , trace = TRUE
                       )$withinss)
}

output_path <- paste(output_dir, "R K-means screeplot.pdf", sep = "/")
pdf(output_path, width = 5, height = 5, useDingbats = FALSE)
plot(1:max_clust, wss, type = "b", xlab = "Number of clusters", ylab = "Within group SS"
     #, log = "y"
)
dev.off()

# calculate clusters and assign colors
n_clusters <- 8
k.c <- kmeans(z, centers = i
              , nstart = 10
              , algorithm = "Hartigan-Wong"
              , trace = TRUE
              , iter.max = 1E+9
)
#k.c$size

clusters <- as.numeric(k.c$cluster)

if(FALSE){
  clusters[which(clusters %in% c(8))] <- 2
  clusters[which(clusters %in% c(6))] <- 4
}

# This is used to hold the shape of the map area, and it can be plotted as a
#   visual aid if necessary
eds_map <- raster(image_path, band = 1)
eds_map[] <- clusters
plot(eds_map, col = hcl.colors(n_clusters, palette = "Hawaii"))

output_path <- paste(output_dir, "R K-means clusters.csv", sep = "/")
write.csv(file = output_path, x = as.matrix(eds_map)
          , row.names = FALSE, quote = FALSE)




