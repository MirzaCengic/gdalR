# Convert raster to polygon
# input_raster Raster* file or path of raster file on disk
# output_file Path of new shapefile
# return_shapefile Logical. If TRUE, function will return a simple feature. Default is FALSE.

GDAL_raster_to_polygon <- function(input_raster, output_file, return_shp = FALSE)
{
  # Add inherits check
  if (inherits(input_raster, "Raster"))
  {
  input_raster_path <- input_raster@file@name
} else {
input_raster_path <- input_raster
}
  
  polygonize_call <- paste0("gdal_polygonize.py", " ", input_raster_path, 
                                               " ", "-f \"ESRI Shapefile\"", " ",
											   output_file)
    
  system(polygonize_call)
  # Return raster
  if (isTRUE(return_shp)) {
    
    out <- sf::st_read(output_file)
    return(out)
  }
}

#### Short example
# writeRaster(lc1, "/vol/milkun1/Mirza_Cengic/Projects/Other/Global_insularity/Data/lc1_test.tif")
# lc1 <- raster("/vol/milkun1/Mirza_Cengic/Projects/Other/Global_insularity/Data/lc1_test.tif")
# example
# lc_poly <- GDAL_raster_to_polygon(lc1, output_file = "/vol/milkun1/Mirza_Cengic/Projects/Other/Global_insularity/Data/Shapefile/landcover.shp", return_shp = TRUE)