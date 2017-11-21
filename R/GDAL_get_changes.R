# Change output name, input rasters, output shape name

#' Extract changed cells from two rasters
#' Get changes from two rasters from different periods. The function is suitable for parallel processing of very large rasters on computers with many cores.
#' 
#' @param x t1 raster
#' @param y t2 raster
#' @param size tilesize
#' @param outpath Folder in which the temporary raster files will be created. If keep_temp argument is set to FALSE (default), files will be deleted after the process is sucessfully executed. Default path is R temporary directory (see tempdir()).
#' @param spatial Logical. When TRUE function returns SpatialPointsDataFrame. Default is FALSE.
#' @param outfile Output file name. Optional.
#' @param crop_category_to_model crop category to subset. Numeric. Accepts vectors.
#'
#' @return
#' @export
#'
#' @examples
get_changes <- function(x, y, size, outpath, outfile,
 values_of_interest, spatial = FALSE, number_of_cores = 2)
{
  stopifnot(!missing(outfile), !missing(values_of_interest))
  #### Define GDAL_mosaic_tiles; change later to load GDAL_mosaic_tiles from github package
 GDAL_mosaic_tiles <- function(output_file, folder_path, return_raster = FALSE, large_tif = FALSE)
{
  folder_path <- paste0(folder_path, "/*.tif")
  
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
  # Return raster
  if (isTRUE(return_raster)) {
    
    out <- raster::raster(output_file)
    return(out)
  }
}
  ###########################
  # Get raster path
  	if (inherits(x, "Raster"))
{
x <- x@file@name
  y <- y@file@name
  } 
  
  
  x_info <- rgdal::GDALinfo(x)
  
   if (missing(size))
  {
  size <- x_info["res.x"] * 1000
  }
  
  tiles_x <- GSIF::getSpatialTiles(x_info, block.x = size, return.SpatialPolygons = FALSE)
  
 if (missing(outpath))
 {
  outpath <- raster::tmpDir()
  }
  
  outdir <- paste0(outpath, "tmpdir") # How to deal with the forwardslash; maybe basename()
    if (!dir.exists(outdir))
	{
	dir.create(outdir)
	}
  
  library(foreach, quiet = TRUE)
  library(doParallel, quiet = TRUE)
  cat(paste0("Running in parallel with ", number_of_cores, " cores."), "\n")
  cl <- makeCluster(number_of_cores)
   registerDoParallel(cl)  
   # Define custom function (opposite of %in%)
   "%ni%" <- Negate("%in%")

  # Foreach loop
   foreach(i = 1:nrow(tiles_x)) %dopar%
  {
    # Get single tile (layer x - t1)
    x_load <- rgdal::readGDAL(x, offset = unlist(tiles_x[i, c("offset.y", "offset.x")]),
                              region.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              output.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              silent = TRUE)
    # Get single tile (layer y - t2)
    y_load <- rgdal::readGDAL(y, offset = unlist(tiles_x[i, c("offset.y", "offset.x")]),
                              region.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              output.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              silent = TRUE)
    
    #### Load tiles as rasters
    x_ras <- raster::raster(x_load)
    y_ras <- raster::raster(y_load)
    #### Filter out the crop category values from t2 raster
    vals <- raster::getValues(y_ras)  
	vals[vals %ni% values_of_interest] <- NA
    y_ras <- raster::setValues(y_ras, vals)
    #### Write raster !!CHANGE PATH!!
    diff_raster <- x_ras - y_ras

	diff_raster_vals <- raster::getValues(diff_raster)
	diff_raster_vals[diff_raster_vals != 0] <- 1	
    diff_raster_vals[diff_raster_vals == 0] <- NA
    diff_raster <- raster::setValues(diff_raster, diff_raster_vals)
	
    # Modify the filename below; modify also so it creates temp folder for the mosaics and deletes files after it's done
    # Use dir.create and check if output file exists then burn everything
    
    
    outmosaic <- paste0(outdir , "/", "tmpmosaic_", i,".tif")
	
    raster::writeRaster(diff_raster, outmosaic, format = "GTiff", overwrite = TRUE, options = c("COMPRESS=LZW"))
  }
  stopCluster(cl)
  # Delete temporary files if final output file exists
  # and if keep_temp argument is true (check if this actually works)
  if (file.exists(outfile)) 
  {
    unlink(outdir)
  }
  
  # Check the bigtiff argument in gdal function
  x_rcl <- GDAL_mosaic_tiles(outfile, folder_path = outdir, large_tif = TRUE, return_raster = TRUE)
  
  x_rcl_points <- raster::rasterToPoints(x_rcl, fun = function(x){x == 1}, sp = spatial) # FINISH!
  return(x_rcl_points)
  
}