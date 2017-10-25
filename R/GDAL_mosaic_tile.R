############################################
# Function to merge the tiled rasters back together
# Output file - path and filename of the mosaicked output (format "E:/Folder/file.tif")
# Folder path - folder path with the tif files to be mosaiced (format "E:/Folder/*.tif")
# argument large_tif = TRUE for large rasters (>4GB)
#
GDAL_mosaic_tiles <- function(output_file, folder_path, return_raster = FALSE, large_tif = FALSE)
{
  
  buildVRT <- paste0("gdalbuildvrt", " ", gsub(pkgmaker::file_extension(output_file),
                                               "vrt", output_file), " ", folder_path)
  if (large_tif == TRUE)
  {
    VRT2TIF <- paste0("gdal_translate -co compress=LZW -co BIGTIFF=YES", " ", gsub(pkgmaker::file_extension(output_file), "vrt", output_file), 
                      " ", gsub(pkgmaker::file_extension(output_file), "tif", output_file))
  } else {
    VRT2TIF <- paste0("gdal_translate -co compress=LZW", " ", gsub(pkgmaker::file_extension(output_file), "vrt", output_file), 
                      " ", gsub(pkgmaker::file_extension(output_file), "tif", output_file))
  }
  
  system(buildVRT)
  system(VRT2TIF)
  # Return raster
  if (isTRUE(return_raster)) {
    
    out <- raster::raster(output_file)
    return(out)
  }
}
