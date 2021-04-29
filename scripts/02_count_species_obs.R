library(data.table)
library(sf)
library(ggplot2)

# load data
data_list = sprintf("data/output/data_ebird_%s.txt", c("ief", "caf", "local"))

# read soib names
soib = fread("data/data_migratory_landbirds_soib.csv")

# read data and count
data = lapply(data_list, function(df) {
    df = fread(df)
    df[, list(`Total observations (2015-2019)` = .N), 
        by = c("SCIENTIFIC NAME", "COMMON NAME")]
})
# add flyway
data = Map(function(df, flyway) {
    df[, flyway := flyway]

    # setorder
    df[, cn_1 := stringi::stri_extract_last(`COMMON NAME`, regex = "\\w+")]
    df[cn_1 == "Whitethroat", "cn_1"] = "Warbler" # must be set manually
    setorder(df, cn_1)
    df[, cn_1 := NULL]
    setnames(df, old = c("SCIENTIFIC NAME", "COMMON NAME"),
        new = c("Scientific name", "Common name"))
    df = merge(df, soib, by.x = "Scientific name", by.y = "scientific_name")

    # also save
    fwrite(df, file = sprintf("data/output/data_candidate_species_%s.csv",
            flyway))
    df
}, data, list("ief", "caf", "local"))
