# Note: This script will only work with an input directory of images
#   with the same dimensions (e.g. a collection of maps from the
#   same area)

library(raster) # used to import element maps as .tifs
rgdal::setCPLConfigOption("GDAL_PAM_ENABLED", "NO") # Disable extra metadata file with geotiff output

# Set up image directory
image_dir <- "C:/Users/Lowell Moore/Downloads/250512 Adam C maps export/22-AC-03/tiff" # Directory containing .tifs of element maps
output_dir <- "C:/Users/Lowell Moore/Downloads/250512 Adam C maps export/bg correction" # Directory where results will go

# preview image of one image channel
image_path <- paste(image_dir, list.files(image_dir)[1], sep = "/")
eds_map <- raster(image_path, band = 1)
plot(eds_map, col = hcl.colors(100, palette = "Hawaii"))
# hcl.pals()


# ----------------------------------------------------------
# Background correction
# ----------------------------------------------------------

# Set subsample size for plotting
flag <- sample(1:length(eds_map), size = 30000, replace = FALSE)

# Identify maps to be background-corrected
list.files(image_dir)
flag_images <- c(4)

# Set COMPO image file
img_compo <- paste(image_dir, list.files(image_dir)[23], sep = "/")
img_compo <- raster(img_compo, band = 1)

# Initialize background correction functions

img_ind <- 1 # Start on the first image in the group

ele_i <- flag_images[img_ind]
if(TRUE){
  img_ele <- paste(image_dir, list.files(image_dir)[ele_i], sep = "/")
  print(paste("Importing --", img_ele))
  img_ele <- raster(img_ele, band = 1)
  xs <- img_compo[flag]
  ys <- img_ele[flag]
  plot(xs, ys)
} # Load and plot

upr_ylim <- 10
if(TRUE){
  x11(); plot(xs, ys
              , ylim = c(0, upr_ylim)
  )
  id_points <- locator(n = 2)
  m <- (id_points$y[2]-id_points$y[1])/(id_points$x[2]-id_points$x[1])
  b <- id_points$y[1] - (m*id_points$x[1])
  abline(b, m, col = "red")
  Sys.sleep(1); dev.off()
  
  #check result
  ys_corr <- ys - ((m*xs) + b)
  plot(xs, ys_corr
       , ylim = c(0, 50)
  )
} # Get BG line info

if(TRUE){
  ele_bg_corr <- img_ele[] - ((m*img_compo[]) + b)
  flag_zeros <- which(ele_bg_corr < 0)
  ele_bg_corr[flag_zeros] <- 0
  eds_map[] <- ele_bg_corr
  file_i_out <- gsub(x = list.files(image_dir)[ele_i]
                     , pattern = "\\.tif", replacement = "_bg_corr\\.tif")
  output_path <- paste(output_dir, file_i_out, sep = "/")
  print(paste("Saving", output_path))
  writeRaster(eds_map, filename = output_path, format = "GTiff", overwrite = TRUE)
} # Save .tif

# increment to the next image
img_ind <- img_ind + 1; ele_i <- flag_images[img_ind]; print(ele_i)
