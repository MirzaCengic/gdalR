# gdalR
Collection of functions that call GDAL externally on the milkun cluster

**NOTE:** Functions are not that general. They're designed to work on milkun cluster (Linux), but can be adapted to be more generalized. Requires GDAL installed.
## Working list of functions utilized right now
* GDAL_LC_tile() - split, process, and merge rasters in parallel
* GDAL_algebra() - raster algebra
* GDAL_aspect() - calculate aspect from DEM
* GDAL_crop() - crop raster with shapefile
* GDAL_mosaic_tile() - lower level function that merges back tiled raster from GDAL_LC_tile
* GDAL_reproject() - reproject raster
* GDAL_resample() - resample raster
* GDAL_slope() - calculate slope from DEM