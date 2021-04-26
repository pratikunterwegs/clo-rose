# use auk via RCall to filter ebird data

using RCall
using XLSX
using DataFrames
# species of interest
# read data from soib
soib = DataFrame(XLSX.readtable("data/2020-state-india-birds-trait-dat.xlsx", "Information")...)
rename!(soib, replace.(names(soib), r" \((India Checklist)\)" => ""))
rename!(soib, replace.(names(soib), " " => "_"))
rename!(soib, lowercase.(names(soib)))

# select all migratory birds then all landbirds
filter!(row -> (occursin(r"(Migratory)", row.migratory_status)), soib)

# print all migratory birds
print(soib.common_name)

# select landbirds of interest -- migratory from europe
soi_query = r"(Cuckoo)|(Roller)|(Wryneck)|(Shrike)|(Lark)|(Flycatcher)|(Warbler)|(Flycatcher)|(throat)|(Thrush)|(chat)|(Wheatear)|(Accentor)|(Wagtail)|(Pipit)|(Rosefinch)|(Bunting)"

filter!(row -> (occursin(soi_query, row.common_name)), soib)

# save and classify manually
CSV.write("data/data_migratory_landbirds_soib.csv", soib)

# remove birds that dont' migrate from europe
soi_ief_query = r"(Drongo)|(Cuckooshrike)|(Lesser Cuckoo)|(Himalayan Cuckoo)|(Grey-backed Shrike)|(Sykes\'s Short-toed)|(Brook)|(Tytler)|(Sulphur-bellied)|(Tickell)|(Smoky)|(Green-crowned)|(Large-billed Leaf)|(Western Crowned)|(Thick-billed)|(Dark-sided)|(Brown-breasted)|(Blue-throated)|(Large Blue)|(Verditer)|(Rubythroat)|(Ultramarine)|(Rusty-tailed)|(Taiga)|(Kashmir)|(Blue-capped)|(Hodgson\'s Bushchat)"

R"library(auk)

  # prepare filters
  file_ebird = file.path('data/observations/ebd_IN_relSep-2020.txt')
  ebd_filters = auk_ebd(file = file_ebird) %>% 
    auk_country(country = 'IN') %>% 
    auk_date(c('2015-01-01', '2019-12-31'))

  # run filters
  file_output = 'data/output/data_ebird.txt'
  ebd_filtered = auk_filter(
    ebd_filters,
    file = file_output,
    overwrite = FALSE
  )"
