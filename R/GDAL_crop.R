# GDAL_crop function draft #####################

# infile - input raster
# outfile - output raster path
# shp - shapfile path
# return raster - set TRUE to load output
GDAL_crop <- function(infile, outfile, shp, return_raster = FALSE)
{
  # Set vrt filename
  outfile_vrt <- gsub(pkgmaker::file_extension(outfile), "vrt", outfile)
  
  # Make system calls
  cut_to_VRT <- paste0("gdalwarp -multi -cutline", " ", shp, " ", "-crop_to_cutline -of vrt", " ", infile, " ", outfile_vrt)
  VRT2TIF <- paste0("gdal_translate -co compress=LZW", " ", outfile_vrt, " ", outfile)

  # Run sytem calls
  system(cut_to_VRT)
  system(VRT2TIF)
  # Remove vrt file
  unlink(outfile_vrt)

  if (isTRUE(return_raster)) {
    library(raster)
    out <- raster::raster(outfile)
    return(out)
  }
}


# Example
# Get region list
regions_list <- list.files("/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Shapefile/IMAGE_regions/Individual_regions", pattern = "shp$")
regions_list <- gsub("_IMAGE.*", "", regions_list)

shapefile_list <- list.files("/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Shapefile/IMAGE_regions/Individual_regions", 
			pattern = "shp$", full.names = TRUE)

			
# Get rasters
raster_names_list <- list.files("/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Predictors/Resampled", pattern = "tif$")
raster_list <- list.files("/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Predictors/Resampled", pattern = "tif$", full.names = TRUE)

library(raster)
library(RStoolbox)

for (region in regions_list)
{

## Crop
# Get index of the shapefile
reg_index <- which(regions_list == as.character(region))

shp_file <- shapefile_list[reg_index]
layer_names <- gsub("_resampled.tif", "", raster_names_list)

folder_path <- "/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Predictors/Resampled_IMAGE_regions/"
region_name <- regions_list[reg_index]

# Check if IMAGE region directory exists
if (!dir.exists(paste0(folder_path, region_name)))
{
  dir.create(paste0(folder_path, region_name))
  message("Output directory created")
}

folder_path_norm <- "/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Predictors/Normalized_IMAGE_regions/"

if (!dir.exists(paste0(folder_path_norm, region_name)))
{
  dir.create(paste0(folder_path_norm, region_name))
  message("Output directory created")
}


# Run over predictors
for (i in seq_along(layer_names))
{
r <- raster_list[i]
cat(paste0("Processing ", layer_names[i], "..."), "\n")
my_ras <- GDAL_crop(r, paste0(folder_path, region_name, "/", layer_names[i], ".tif"), shp_file, return_raster = TRUE)
cat(paste0("Normalizing ", layer_names[i], "..."), "\n")
my_ras <- normImage(my_ras, norm = TRUE)
cat("Writing raster...", "\n")
writeRaster(my_ras, paste0(folder_path_norm, region_name, "/", layer_names[i], "_norm.tif"), format = "GTiff")
}
}