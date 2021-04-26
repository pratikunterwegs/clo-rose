# code filter SOIB data for migratory species

using CSV
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

# select landbirds of interest by common name
soi_query = r"(Cuckoo)|(Roller)|(Wryneck)|(Shrike)|(Lark)|(Flycatcher)|(Warbler)|(Flycatcher)|(throat)|(Thrush)|(chat)|(Wheatear)|(Accentor)|(Wagtail)|(Pipit)|(Rosefinch)|(Bunting)"

filter!(row -> (occursin(soi_query, row.common_name)), soib)

# save and classify manually
CSV.write("data/data_migratory_landbirds_soib.csv", soib)
