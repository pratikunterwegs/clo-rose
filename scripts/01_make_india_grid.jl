# use RCall to make a 100 km grid over south asia

using RCall

# get south asian countries as sf at coarse scale
R"library(rnaturalearth); library(sf)"
R"sasia = data = st_as_sf(rnaturalearth::countries110)"
R"sasia = (sasia)[sasia$name %in% c('India', 'Nepal', 'Pakistan', 'Bangladesh', 'Sri Lanka', 'Bhutan'), ]"

# plot for sanity
R"library(ggplot2)"
R"ggplot(sasia) + geom_sf(aes(fill = name))"

# sample with 100km hexagons
R"sasia = st_transform(sasia, 32643)"
R"sasia_grid = st_make_grid(sasia, cellsize = 100 * 1e3, square = F, what = 'polygons')"

# check intersection and keep intersecting polygons
R"intersect_grid = st_intersects(sasia, sasia_grid)"
R"intersect_grid = unique(unlist(unclass(intersect_grid)))"
R"sasia_grid = sasia_grid[intersect_grid]"

# plot for sanity
R"library(ggplot2)"
R"ggplot(sasia) + 
    geom_sf(colour = NA,
            fill = 'tan') +
    geom_sf(data = sasia_grid,
            fill = NA,
            colour = 'white')"

# save the grid
R"st_write(sasia_grid, dsn = 'data/data_grid.gpkg')"
