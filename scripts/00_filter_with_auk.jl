# use auk via RCall to filter ebird data

using RCall
using CSV
using DataFrames

# read manually annotated file
soib = CSV.read("data/data_migratory_landbirds_soib.csv", DataFrame)

R"library(auk)"

# get species of interest
flyways = ["ief", "caf", "local"]
for flyway in flyways
  soi = filter(row -> occursin(flyway, row.flyway), soib)
  soi = soi.scientific_name

  path = string("data/output/data_ebird_", flyway, ".txt")

  R"
  # prepare filters
  file_ebird = file.path('data/ebd_IN_relSep-2020.txt')
  ebd_filters = auk_ebd(file = file_ebird) %>% 
    auk_species($soi) %>%
    auk_country(country = 'IN') %>% 
    auk_date(c('2015-01-01', '2019-12-31'))

  # run filters
  file_output = $path
  ebd_filtered = auk_filter(
    ebd_filters,
    file = file_output,
    overwrite = TRUE
  )"
end
