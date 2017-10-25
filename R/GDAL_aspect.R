# GDAL_aspect
# zero_flat argument returns 0 for flat areas instead of -9999. Default is TRUE.
GDAL_aspect <- function(infile, outfile, zero_flat = TRUE, return_raster = FALSE)
{
  
  if(isTRUE(zero_flat))
  {  
    GDAL_call <- paste0("gdaldem aspect -compute_edges -zero_for_flat", " ", infile, " ", outfile)
  } else {
    GDAL_call <- paste0("gdaldem aspect -compute_edges", " ", infile, " ", outfile)
    
  }
  
  system(GDAL_call)
  
  if( isTRUE(return_raster)){
    r_slope <- raster::raster(outfile)
    return(r_slope)
  }
}