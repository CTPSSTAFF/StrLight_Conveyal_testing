library(r5r)
library(tidyverse)
library(sf)
library(tictoc)

options(java.parameters = "-Xmx75G")
rJava::.jinit()

path <- "C:/Users/bbact/Desktop/r5r_directory"
r5r_core <- setup_r5(data_path = path, verbose = F)

#points <- read.csv(system.file("extdata/poa/poa_hexgrid.csv", package = "r5r"))
taz_centroids <- st_read("Data/StreetLight/TAZ_Centroids/TAZ_Centroids.shp")

taz_grid <- st_read("Data/StreetLight/TAZ_Centroids/Moderate_400m_grid.shp")
taz_grid$id <- seq.int(nrow(taz_grid))
taz_xy <- taz_grid %>%
  mutate(long = unlist(map(taz_grid$geometry,1)),
         lat = unlist(map(taz_grid$geometry,2))) %>% 
  select(id,geometry,lat,long)


taz_xy <- taz_centroids %>%
  mutate(long = unlist(map(TAZ_centroids$geometry,1)),
         lat = unlist(map(TAZ_centroids$geometry,2))) %>% 
           select(name,geometry,lat,long) %>% 
  rename(id = name)

mode <- c("WALK", "TRANSIT")
max_walk_dist <- 1600   # meters
max_trip_duration <- 120 # minutes
departure_datetime <- as.POSIXct("13-05-2019 14:00:00",
                                 format = "%d-%m-%Y %H:%M:%S")

tic()
# 3.1) calculate a travel time matrix
ttm <- travel_time_matrix(r5r_core = r5r_core,
                          origins = taz_xy,
                          destinations = taz_xy,
                          mode = mode,
                          departure_datetime = departure_datetime,
                          max_walk_dist = max_walk_dist,
                          max_trip_duration = max_trip_duration,
                          breakdown = TRUE,
                          verbose = FALSE,
                          progress = TRUE,
                          breakdown_stat = "min")
time_to_calculate <- toc() # 1 minute and 55GB of RAM to compute 8718 OD pairs

det  <- detailed_itineraries(r5r_core = r5r_core,
                             origins = taz_xy,
                             destinations = taz_xy,
                             mode = mode,
                             departure_datetime = departure_datetime,
                             max_walk_dist = max_walk_dist,
                             max_trip_duration = max_trip_duration,
                             shortest_path = T,
                             drop_geometry = FALSE)

st_write(det,"Data/StreetLight/TAZ_Centroids/itineraries.shp")
