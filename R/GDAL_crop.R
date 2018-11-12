# GDAL_crop function draft #####################

#' Crop raster
#'
#' The function crops rasters (to the shapefile boundary) using GDAL. Use only filepaths (not rasters/shapefiles loaded in R environment).
#'
#' @param input_raster Character. Raster to be cropped (file path or Raster object). Input raster should be stored on disk for GDAL access.
#' @param filename Character. Output raster path.
#' @param shapefile_path Character. Filepath of a shapefile or geopackage. that is used to crop the raster. Disk path, \strong{not sp or sf object}.
#' @param large_tif Logical. Use \code{large_tif = TRUE} for large rasters (>4GB).
#' @param return_raster Logical. The function stores the raster in the \code{filename} argument path as a side-effect.
#'
#' @return Raster object. Only if \code{return_raster = TRUE}. Otherwise, the function side-effect is to save the file locally.
#' @export
#'
#' @importFrom tools file_ext
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

GDAL_crop <- function(input_raster, filename, shapefile_path, large_tif = FALSE, return_raster = TRUE)
{

  if (missing(filename))
  {
    filename <- tempfile(fileext = ".tif")
    warning("Argument filename is missing. Temporary raster file will be created.")
  }
  # Set vrt filename
  outfile_vrt <- gsub(tools::file_ext(filename), "vrt", filename)

  	if (inherits(input_raster, "Raster"))
{
  input_raster <- input_raster@file@name
 }

  # Make system calls
  cut_to_VRT <- paste0("gdalwarp -multi -cutline", " ", shapefile_path, " ", "-crop_to_cutline -of vrt", " ", input_raster, " ", outfile_vrt)

  if (large_tif == TRUE)
  {
    VRT2TIF <- paste0("gdal_translate -co compress=LZW -co BIGTIFF=YES", " ", outfile_vrt, " ", filename)
  } else {
    VRT2TIF <- paste0("gdal_translate -co compress=LZW", " ", outfile_vrt, " ", filename)
  }

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
