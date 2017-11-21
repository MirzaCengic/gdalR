# Function to resample raster to a different resolution.
# x is raster to be resampled
# output_file is filename of the output raster with the whole path
# Target resolution (Add option to read resolution from other raster)
# Method - gdal.org/gdalwarp.html


#############
GDAL_resample <- function(infile, outfile, target_resolution, method, large_tif = FALSE, return_raster = FALSE)
{
  
 if (!method %in% c("near", "bilinear", "cubic", "cubicspline", "lanczos",
                     "average", "mode", "max", "min", "med", "q1", "q3")) {
    stop("Resampling method not available.")
    }
  
  # If input is raster, extract the file path 
  if (inherits(infile, "Raster"))
{
  infile <- infile@file@name
 } 
  
resample_command <- paste0("gdalwarp -multi -of vrt -tr ", " ", target_resolution, " ", target_resolution, " -r ", method, " ",
 infile, " ", gsub(pkgmaker::file_extension(outfile), "vrt", outfile))
 
  if (large_tif == TRUE)
  {
    VRT2TIF <- paste0("gdal_translate -co compress=LZW -co BIGTIFF=YES", " ", gsub(pkgmaker::file_extension(outfile), "vrt", outfile), 
                      " ", gsub(pkgmaker::file_extension(outfile), "tif", outfile))
  } else {
    VRT2TIF <- paste0("gdal_translate -co compress=LZW", " ", gsub(pkgmaker::file_extension(outfile), "vrt", outfile), 
                      " ", gsub(pkgmaker::file_extension(outfile), "tif", outfile))
  }
  
  system(resample_command) 
  system(VRT2TIF)
  # Remove vrt
  unlink(gsub(pkgmaker::file_extension(outfile), "vrt", outfile))

  if (isTRUE(return_raster))
  {
    outfile <- raster::raster(outfile)
	return(outfile)
  }
}

# Example
# lc_info <- "/vol/milkun1/Mirza_Cengic/Data_RAW/ESA_CCI/TIFF/YearByYear/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2002-v2.0.7.tif"
# out <- "/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Predictors/Resampled/Soil_GDAL/Soil_AWCh.tif"
# awch <- "/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Predictors/Original/Soil/Soil_AWCh.tif"
# res_lc <- rgdal::GDALinfo(lc_info)["res.x"]
# GDAL_resample(awch, outfile = out,
 # target_resolution = res_lc, method = "average", large_tif = TRUE)

