
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- output: rmarkdown::github_document -->
<!-- output: html_notebook -->
gdalR package
=============

This is a repo for package that contains a collection of functions that call GDAL externally on the [milkun cluster](http://wiki.science.ru.nl/cncz/Hardware_servers?setlang=en#.5BReken-.5D.5BCompute_.5Dservers.2Fclusters).

To install the package, run:

``` r
devtools::install_github("mirzacengic/gdalR")
```

**NOTE:** Functions are not that general. They're designed to work on milkun cluster (Linux), but can be adapted to be more generalized. Requires GDAL installed. \#\# Working list of functions utilized right now - GDAL\_LC\_tile() - split, process, and merge rasters in parallel.
- GDAL\_algebra() - raster algebra.
- GDAL\_aspect() - calculate aspect from DEM.
- GDAL\_crop() - crop raster with shapefile. *Only this function has some documentation.*
- GDAL\_mosaic\_tile() - lower level function that merges back tiled raster from GDAL\_LC\_tile.
- GDAL\_reproject() - reproject raster.
- GDAL\_resample() - resample raster.
- GDAL\_slope() - calculate slope from DEM.
- GDAL\_get\_changes() - extract changes from two raster from different timesteps with gdal\_calc.py. **Needs debugging!**
- GDAL\_raster\_to\_polygon() - convert raster to a polygon (ESRI Shapefile) using gdal\_polygonize.py.
