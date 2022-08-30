library(tidyverse)


stops <- read.csv("Data/BNR_GTFS/gtfs_bnrd_041922/stops.txt")

# stops %>% filter(stop_id == "place-armnl")

stops$parent_station <- NA

write_delim(stops,"Data/BNR_GTFS/gtfs_bnrd_041922_v2/stops.txt",delim = ",",na="\"\"")

# 
# stops_base <- read.csv("Data/BNR_GTFS/gtfs_base_031522_v2/stops.txt")
# unique(stops_base$parent_station)
