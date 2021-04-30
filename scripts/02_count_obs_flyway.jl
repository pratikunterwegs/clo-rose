# code to count observations

using CSV
using DataFrames

# which files
paths = ["ief", "caf", "local"]
for i in 1:length(paths)
    paths[i] = string("data/output/data_candidate_species_", paths[i], ".csv")
end

# soib
soib = CSV.read("data/data_migratory_landbirds_soib.csv", DataFrame)

# function to work on flyway data
for flyway in flyways
    file_path = string("data/output/data_ebird_",
        flyway, ".txt")
    df = CSV.read(path, DataFrames)
    rename!(df, replace.(names(df), " " => "_"))
    rename!(df, lowercase.(names(df)))

    # count observations
    df = combine(groupby(df, [:scientific_name, :common_name]),
        nrow => :observations)

    # assign flyway
    df[!, :flyway] .= flyway
    df.family = last.(split.(df.common_name))
    df.family = ifelse.(df.family .== "Whitethroat", "Warbler", df.family)

    # join with soib
    df = leftjoin(df, soib, on = "scientific_name")

    # save
    CSV.write("data/output/data_candidate_species_" + flyway + ".csv") 
end
