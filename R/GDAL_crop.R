# GDAL_crop function draft #####################

#' Crop raster
#'
#' The function crops rasters (to the shapefile boundary) using GDAL.
#'
#' @param input_raster Raster to be cropped (file path or Raster object). Input raster should be stored on disk for GDAL access.
#' @param filename Output raster path.
#' @param shapefile_path Shapefile that is used to crop the raster. Disk path, \strong{not sp or sf object}.
#' @param return_raster Logical. The function stores the raster in the \code{filename} argument path as a side-effect.
#'
#' @return
#' @export
#'
#' @importFrom pkgmaker file_extension
#' @importFrom raster raster
#' @examples
#' library(gdalR)
#' library(Rahat)
#'
#' we_eu <- milkunize("Projects/Land_use/Data/Shapefile/IMAGE_regions/Individual_regions/Western_Europe_IMAGE.shp")
#' dem <- milkunize("Merit_DEM_10s.tif", "m5")
#'
#' # Crop dem
#' dem_cropped <- GDAL_crop(dem, filename = "/vol/milkun1/Mirza_Cengic/Temp/dem_we.tif", shapefile_path = we_eu)

GDAL_crop <- function(input_raster, filename, shapefile_path, return_raster = TRUE)
{

  if (missing(filename))
  {
    filename <- tempfile(fileext = ".tif")
    warning("Argument filename is missing. Temporary raster file will be created.")
  }
  # Set vrt filename
  outfile_vrt <- gsub(pkgmaker::file_extension(filename), "vrt", filename)

  	if (inherits(input_raster, "Raster"))
{
  input_raster <- input_raster@file@name
 }

  # Make system calls
  cut_to_VRT <- paste0("gdalwarp -multi -cutline", " ", shapefile_path, " ", "-crop_to_cutline -of vrt", " ", input_raster, " ", outfile_vrt)
  VRT2TIF <- paste0("gdal_translate -co compress=LZW", " ", outfile_vrt, " ", filename)

  # Run sytem calls
  system(cut_to_VRT)
  system(VRT2TIF)
  # Remove vrt file
  unlink(outfile_vrt)

  if (return_raster)
  {
    library(raster)
    out <- raster::raster(filename)
    return(out)
  }
}
