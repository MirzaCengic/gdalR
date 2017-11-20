# Perform raster algebra with GDAL from R
# Argument operation is the operation to be carried between two rasters eg. "A+B"


GDAL_algebra <- function(input1, input2, outfile = "", operation, format = "GTiff", return_raster = FALSE, overwrite = FALSE)
{

stopifnot(operation)

  if(file.exists(outfile)) 
  {
    if(overwrite == TRUE)
    {
      unlink(outfile)
    } else {
      stop("Outfile already exists --- Set overwrite = TRUE to overwrite.")
    }
  }
 
# If input is raster, extract the file path 
  if (inherits(input1, "Raster"))
{
  input1 <- input1@file@name
  input2 <- input2@file@name
 } 
  to_run <- paste0(
    "gdal_calc.py --co compress=LZW -A", " ", input1, " ", "-B", " ", input2, " ", 
    "--type Float32 --outfile=", outfile, " ", "--format=", format," ", "--calc=", '\"', operation, '\"')
 
  system(to_run)  
  if (isTRUE(return_raster)) {
    library(raster)
    out <-raster(outfile)
    return(out)
  }
}