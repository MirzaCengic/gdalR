################################################
# Function for reprojecting rasters with GDAL
# Change default CRS, change reprojection method, 
GDAL_reproject <- function(input, outfile, crs_target, method, return_raster = FALSE)
{
 if (!method %in% c("near", "bilinear", "cubic", "cubicspline", "lanczos",
                     "average", "mode", "max", "min", "med", "q1", "q3")) {
    stop("Resampling method not available.")
    }

proj.cmd.warp <- paste0("gdalwarp -t_srs", " ", "'",
 crs_target,"'" , " ","-r", " ", method, " ", "-of vrt")

print(paste(proj.cmd.warp, input, gsub(pkgmaker::file_extension(outfile), "vrt", outfile)))
# Reproject to vrt in order to conserve space
system(command = paste(proj.cmd.warp, input, gsub(pkgmaker::file_extension(outfile), "vrt", outfile)))
# Load and transform to tiff
system(paste("gdal_translate -co compress=LZW", gsub(pkgmaker::file_extension(outfile), "vrt", outfile),
outfile))
# Remove vrt file
unlink(gsub(pkgmaker::file_extension(outfile), "vrt", outfile))

# Return raster
 if (isTRUE(return_raster)) {
  library(raster)
  out <-raster(outfile)
  return(out)
}
}

#EX
esa <- "/vol/milkun1/Mirza_Cengic/Data_RAW/ESA_CCI/TIFF/YearByYear/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2002-v2.0.7.tif"
out <- "/vol/milkun1/Mirza_Cengic/Projects/Land_use/Data/Mask/LC_mollweide.tif"
proj <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
GDAL_reproject(esa, out, crs_target = proj, method = "near")