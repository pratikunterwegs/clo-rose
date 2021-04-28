# test hexagonal binning of SWG obs
library(data.table)
library(sf)
library(ggplot2)

# load data
data = fread("data/output/data_ebird_ief_coords.csv")

# load grid
grid = st_read("data/data_grid.gpkg")

# check intersection
obs_coords = st_as_sf(
  data[, c("longitude", "latitude")],
  coords = c("longitude", "latitude"),
  crs = 4326
  ) %>%
  st_transform(32643)
obs_intersection = st_intersects(obs_coords, grid)

# remove some data
good_rows = unlist(lapply(unclass(obs_intersection), function(x) length(x) > 0))
data = data[good_rows,]

# assign polygon id
data$polygon = unlist(unclass(obs_intersection))

# save
fwrite(data, file = "data/output/data_ief_polygons.csv")
