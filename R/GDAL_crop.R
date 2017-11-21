# GDAL_crop function draft #####################

# infile - input raster
# outfile - output raster path
# shp - shapfile path
# return raster - set TRUE to load output
GDAL_crop <- function(infile, outfile, shp, return_raster = FALSE)
{
  # Set vrt filename
  outfile_vrt <- gsub(pkgmaker::file_extension(outfile), "vrt", outfile)
  
  	if (inherits(infile, "Raster"))
{
  infile <- infile@file@name
 } 
  
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
