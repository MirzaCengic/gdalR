# Function that tiles rasters and performs specific calculations in parallel
# In this case rasters are reclassified so that specific category is excluded

GDAL_LC_tile <- function(x, size, outpath, mosaic = FALSE, outfile, crop_category_to_model = NA, return_raster = FALSE)
{
  if(missing(outpath)){stop("Specify outpath.")}
  
  # Get header of the object
  obj_x <- rgdal::GDALinfo(x)
  # Create spatial tiles for tiling; Creating 2 tile objects might be redundant
  tiles_x <- GSIF::getSpatialTiles(obj_x, block.x = size, return.SpatialPolygons = FALSE)
  
  #### Set values to be included and excluded
  # Category 10, 11, 12 or 666 (use 10, 11, 12 for separate modeling, 666 just have when all rainfed categories are used)
  if(crop_category_to_model %in%  c(10:12, 666))
  {
    values_excluded <- c(10, 11, 12)
  } else if(crop_category_to_model == 20)
  {
    values_excluded <- 20
  } else if(crop_category_to_model == 30)
  {
    values_excluded <- 30
  } else if(crop_category_to_model == 40)
  {
    values_excluded <- 40
  } else if(crop_category_to_model == 999) # 999 is for all crops
  {
    values_excluded <- c(10:41, 190, 210)
  } else {stop("Enter crop category to model")}
  ###########################################
  # Values for all of the possible categories
  all_categories <- 1:221
  # Urban values 
  urban <- 190
  # Values to include and exclude
  vals_excluded <- c(values_excluded, urban)
  vals_included <- all_categories[-values_excluded] 
  # Loop in parallel over mosaic tiles
  for (i in 1:nrow(tiles_x))
  # foreach(i = 1:nrow(tiles_x)) %dopar%
  {
    library(raster)
    # Get single tile (layer x)
    x_load <- rgdal::readGDAL(x, offset = unlist(tiles_x[i, c("offset.y", "offset.x")]),
                              region.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              output.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              silent = TRUE)
    
    #### Load tiles as rasters
    x_ras <- raster::raster(x_load)
    
    #### Reclassify
    
    vals <- raster::getValues(x_ras)  
    vals[vals %in% vals_included] <- 1  
    vals[vals %in% vals_excluded] <- 0
    x_ras <- raster::setValues(x_ras, vals)
    #### Write raster !!CHANGE PATH!!
    outmosaic <- paste0(outpath ,"Mosaic_", i,".tif")
    raster::writeRaster(x_ras, outmosaic, format = "GTiff", overwrite = TRUE)
  }
  if (isTRUE(mosaic))
  {
    if (missing(outfile)) 
    {
      stop("Output filename missing.")
    }
    outdir <- paste0(outpath, "*.tif")
    x_rcl <- GDAL_mosaic_tiles(outfile, folder_path = outdir, large_tif = TRUE, return_raster=return_raster)
    }
  if (isTRUE(return_raster))
  {
    return(x_rcl)
  }
}


# This function is to reclassify output of the function above

GDAL_LC_tile2 <- function(x, size, outpath, mosaic = FALSE, outfile, return_raster = FALSE)
{
  if(missing(outpath)){stop("Specify outpath.")}
  
  # Get header of the object
  obj_x <- rgdal::GDALinfo(x)
  # Create spatial tiles for tiling; Creating 2 tile objects might be redundant
  tiles_x <- GSIF::getSpatialTiles(obj_x, block.x = size, return.SpatialPolygons = FALSE)
  
  #### Set values to be included and excluded
  # Category 10, 11, 12 or 666 (use 10, 11, 12 for separate modeling, 666 just have when all rainfed categories are used)
  
  # Loop in parallel over mosaic tiles
    for (i in 1:nrow(tiles_x))
  # foreach(i = 1:nrow(tiles_x)) %dopar%
  {
    library(raster)
    # Get single tile (layer x)
    x_load <- rgdal::readGDAL(x, offset = unlist(tiles_x[i, c("offset.y", "offset.x")]),
                              region.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              output.dim = unlist(tiles_x[i, c("region.dim.y", "region.dim.x")]), 
                              silent = TRUE)
    
    #### Load tiles as rasters
    x_ras <- raster::raster(x_load)
    
    #### Reclassify
    
    vals <- raster::getValues(x_ras)  
     vals[vals != 2] <- NA  
    x_ras <- raster::setValues(x_ras, vals)
    #### Write raster !!CHANGE PATH!!
    outmosaic <- paste0(outpath , "Mosaic_", i,".tif")
    raster::writeRaster(x_ras, outmosaic, format = "GTiff", overwrite = TRUE)
  }
  if (isTRUE(mosaic))
  {
    if (missing(outfile)) 
    {
      stop("Output filename missing.")
    }
    outdir <- paste0(outpath, "*.tif")
    x_rcl <- GDAL_mosaic_tiles(outfile, folder_path = outdir, large_tif = TRUE, return_raster=return_raster)
    }
  if (isTRUE(return_raster))
  {
    return(x_rcl)
  }
}
