# LangeCoastalRidging
This repository contains code that was used to identify and measure grounded ridges along the Alaskan Arctic coastlines from ICESat-2 data

bulktrackprocessing.m is the main branch of code which processes each ICESat-2 track
distance_sparse.m calculated the distance of each photon return to the coastline
fdd_thickness.m calculated the ice thickness for any date using heightBeau.mat and heightChuk.mat of the compiled thickness from different models

Coastline2021.shp is a trace of the coastline over the study area we use
Contour-20.shp is the 20m bathymetric contour from GEBCO
SLIE2022Projected.shp is the landfast ice edge for 2022 from Cooley et al., 2024
