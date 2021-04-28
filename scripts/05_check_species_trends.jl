# plots of species status

using CSV
using DataFrames
using XLSX
using StatsBase
using Statistics

# load ief species
data = CSV.read("data/output/data_candidate_species.csv", DataFrame)
rename!(data, replace.(names(data), r"(-)|\((\%)\)" => ""))

# load soib
soib = DataFrame(XLSX.readtable("data/2020-state-india-birds-trait-dat.xlsx", "Information")...)
rename!(soib, replace.(names(soib), r" \((India Checklist)\)|(-)|\((\%)\)" => ""))
rename!(soib, replace.(names(soib), " " => "_"))
rename!(soib, lowercase.(names(soib)))

# antijoin
soib = antijoin(soib, data, on = "scientific_name")
filter!(row -> !(row.longterm_trend_ == "NA"), soib)
soib.longterm_trend_ = Float64.(soib.longterm_trend_)

# average trend in ief species
function mean_na(x)
    mean(skipmissing(x))
end
function sd_na(x)
    std(skipmissing(x))
end

# join data
data_trend = vcat(combine(data, :longterm_trend_ .=> [mean_na, sd_na]),
     combine(soib, :longterm_trend_ .=> [mean_na, sd_na]))
data_trend.flyway = ["ief", "other"]
CSV.write("data/output/data_trend.csv", data_trend)
