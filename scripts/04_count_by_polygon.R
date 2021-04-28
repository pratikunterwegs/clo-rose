# count IEF species obs
library(data.table)
library(sf)
library(ggplot2)

# load data
data = fread("data/output/data_ief_polygons.csv")

# read soib names
soib = fread("data/data_migratory_landbirds_soib.csv")

# count by polygon and species
data_count = data[, .N, by = c("scientific_name", "polygon")]

# count total obs by species
data_sp_count = data[,.N, by = "scientific_name"]
data_sp_count = merge(data_sp_count, soib, by = "scientific_name")

# load grid
grid = st_read("data/data_grid.gpkg")
grid$polygon = seq(nrow(grid))

# load sasia
sasia = st_as_sf(rnaturalearth::countries110) %>%
    dplyr::filter(name %in% c("India", "Pakistan", "Bangladesh", "Nepal", "Bhutan",
                    "Sri Lanka"))

# join polygons and counts
grid = dplyr::left_join(grid, data_count, by = "polygon")
grid = grid[!(is.na(grid$scientific_name)),]
grid = dplyr::left_join(grid, soib[, c("common_name", "scientific_name")])

# to order by common name
grid$cn_1 = factor(stringi::stri_extract_last(grid$common_name,regex= "\\w+"))
grid[grid$cn_1 == "Whitethroat",]$cn_1 = "Warbler" # must be set manually
grid$common_name = forcats::fct_reorder(grid$common_name, as.numeric(grid$cn_1))

# transform
grid = st_transform(grid, 4326)

# plot figure
x11()
fig_observations = 
    ggplot()+
    geom_sf(data = sasia,
        fill = "grey90",
        colour = NA
    )+
    geom_sf(data = grid,
            aes(fill = N),
            colour = NA
    )+
    geom_text(
        data = data_sp_count,
        aes(
            x = 70, y = 10, 
            label = sprintf("Total:\n%s", scales::comma(N))
        ),
        size = 2
    )+
    scale_fill_viridis_c(
        option = "F",
        direction = -1,
        trans = "log10",
        labels = scales::comma
    )+
    facet_wrap(~common_name+scientific_name)+
    theme_void(base_size = 8)+
    theme(
        strip.text = element_text(face = "bold", hjust = 0),
        legend.position = "top",
        legend.key.width = unit(5, "mm"),
        legend.key.height = unit(1, "mm")
    )+
    labs(
        fill = "Observations",
        title = "Observation counts for potential 'Indo-European Flyway' species",
        caption = "Data source: eBird India dump 2015 -- 2019"
    )
# save
ggsave(fig_observations, filename = "figures/fig_ief_sp_obs.png",
        height = 10, width = 10)
