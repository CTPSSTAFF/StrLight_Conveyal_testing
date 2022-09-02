library(r5r)
library(tidyverse)
library(sf)
#library(tictoc)
library(osmextract)


route_between_points <- function(network,od_points, sys_memory){
  #java_ram <- paste0("-Xmx",sys_memory,"G")
  #options(java.parameters = java_ram)
  #rJava::.jinit()
  
  # oe_download_directory("input/Base_network")
  # 
  # oe_get("us/rhode-island",provider = "geofabrik")
  # pbf_name <- paste0("geofabrik_",tail(strsplit(oe_match("us/rhode-island",provider = "geofabrik")$url,split="/")[[1]],n=1))
  # temp_loc <- file.path(tempdir(),pbf_name)
  # proj_loc <- file.path(getwd(),"Data/input/Base_network",pbf_name)
  # file.copy(from = temp_loc, to = proj_loc, overwrite = TRUE)
  # 
  # oe_get("us/massachusetts",provider = "geofabrik")
  # pbf_name <- paste0("geofabrik_",tail(strsplit(oe_match("us/massachusetts",provider = "geofabrik")$url,split="/")[[1]],n=1))
  # temp_loc <- file.path(tempdir(),pbf_name)
  # proj_loc <- file.path(getwd(),"Data/input/Base_network",pbf_name)
  # file.copy(from = temp_loc, to = proj_loc, overwrite = TRUE)
  # 
  # 
  # r5r_core <- setup_r5(data_path = "input/Base_network", verbose = F)
  
  
  #points <- read.csv(system.file("extdata/poa/poa_hexgrid.csv", package = "r5r"))
  #taz_centroids <- st_read("Data/StreetLight/TAZ_Centroids/TAZ_Centroids.shp")
  
  #taz_grid <- st_read("Data/StreetLight/TAZ_Centroids/Moderate_400m_grid.shp")
  #taz_grid$id <- seq.int(nrow(taz_grid))
  # od_points <- od_points %>%
  #   mutate(long = unlist(map(od_points$geometry,1)),
  #          lat = unlist(map(od_points$geometry,2))) %>% 
  #   select(id,geometry,lat,long)
  
  
  # taz_xy <- taz_centroids %>%
  #   mutate(long = unlist(map(TAZ_centroids$geometry,1)),
  #          lat = unlist(map(TAZ_centroids$geometry,2))) %>% 
  #            select(name,geometry,lat,long) %>% 
  #   rename(id = name)
  
  mode <- c("WALK", "TRANSIT")
  max_walk_dist <- 1600   # meters
  max_trip_duration <- 120 # minutes
  departure_datetime <- as.POSIXct("13-05-2019 14:00:00",
                                   format = "%d-%m-%Y %H:%M:%S")
  
  #tic()
  # 3.1) calculate a travel time matrix
  ttm <- travel_time_matrix(r5r_core = network,
                            origins = od_points,
                            destinations = od_points,
                            mode = mode,
                            departure_datetime = departure_datetime,
                            max_walk_dist = max_walk_dist,
                            max_trip_duration = max_trip_duration,
                            breakdown = TRUE,
                            verbose = FALSE,
                            progress = TRUE,
                            breakdown_stat = "min")
  #time_to_calculate <- toc() # 1 minute and 55GB of RAM to compute 8718 OD pairs
  
  # det  <- detailed_itineraries(r5r_core = r5r_core,
  #                              origins = taz_xy,
  #                              destinations = taz_xy,
  #                              mode = mode,
  #                              departure_datetime = departure_datetime,
  #                              max_walk_dist = max_walk_dist,
  #                              max_trip_duration = max_trip_duration,
  #                              shortest_path = T,
  #                              drop_geometry = FALSE)
  # 
  # st_write(det,"Data/StreetLight/TAZ_Centroids/itineraries.shp")
  return(ttm)

}
