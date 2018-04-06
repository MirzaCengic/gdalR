############################################
# Function to merge the tiled rasters back together
# Output file - path and filename of the mosaicked output (format "E:/Folder/file.tif")
# Folder path - folder path with the tif files to be mosaiced (format "E:/Folder/*.tif")
# argument large_tif = TRUE for large rasters (>4GB)
#
#' Mosaic raster tiles
#'
#' @param output_file Path and filename of the mosaicked output (format "E:/Folder/file.tif")
#' @param folder_path Folder path with the tif files to be mosaiced (format "E:/Folder/*.tif")
#' @param return_raster Return raster.
#' @param large_tif Use \code{large_tif = TRUE} for large rasters (>4GB)
#'
#' @return Raster.
#' @export
#'
#' @examples None.
#' @importFrom pkgmaker file_extension
#' @importFrom raster raster
#'
GDAL_mosaic_tile <- function(output_file, folder_path, return_raster = TRUE, large_tif = TRUE)
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
  unlink(gsub(pkgmaker::file_extension(output_file),
              "vrt", output_file))
  # Return raster
  if (return_raster) {

    out <- raster::raster(output_file)
    return(out)
  }
}
