# Function to calculate slope
# degrees unit argument is for input rasters with degrees as horizontal unit (i.e. lat/long).
# If input is projected, set degrees_unit to FALSE
GDAL_slope <- function(infile, outfile, degrees_unit = TRUE, return_raster = FALSE)
{
  
  if(isTRUE(degrees_unit))
  {  
    GDAL_call <- paste0("gdaldem slope -compute_edges -s 111120", " ", infile, " ", outfile)
  } else {
    GDAL_call <- paste0("gdaldem slope -compute_edges", " ", infile, " ", outfile)
    
  }
  
  system(GDAL_call)
  
  if( isTRUE(return_raster)){
    r_slope <- raster::raster(outfile)
    return(r_slope)
  }
}