library(r5r)
library(tidyverse)
library(sf)
#library(tictoc)
library(osmextract)


route_between_points <- function(network,od_points, start_hour,end_hour){

  
  mode <- c("WALK", "TRANSIT")
  max_walk_dist <- 1600   # meters
  max_trip_duration <- 120 # minutes
  
  
  departure_datetime <- as.POSIXct(paste0("11-05-2019 ",start_hour,":00:00"),
                                   format = "%d-%m-%Y %H:%M:%S")

  #tic()
  # 3.1) calculate a travel time matrix
  ttm1 <- travel_time_matrix(r5r_core = network,
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
  dow <- weekdays(departure_datetime,abbreviate = T)
  col_name <- paste0("hr_",start_hour,"_",dow)
  ttm1 <- ttm1 %>% select("fromId","toId","travel_time") %>% 
    rename(!!col_name := "travel_time")
  
  #loop through times
  hour_list <- seq.int(as.numeric(start_hour)+1,as.numeric(end_hour))
  hour_list_str <- paste0(str_pad(hour_list , width = 2, side = "left", pad = 0))
  date_list <- c("11-05-2019 ","12-05-2019 ","13-05-2019 ")
  
  first_loop <- T
  for (date in date_list){
    
    for (hr in hour_list_str){
      departure_datetime <- as.POSIXct(paste0(date,hr,":00:00"),
                                       format = "%d-%m-%Y %H:%M:%S")
      if (first_loop == T){
      ttm1 <- travel_time_matrix(r5r_core = network,
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
      dow <- weekdays(departure_datetime,abbreviate = T)
      col_name <- paste0("hr_",hr,"_",dow)
      ttm1 <- ttm1 %>% select("fromId","toId","travel_time") %>% 
        rename(!!col_name := "travel_time")
      first_loop <- F
      
      }else{
        
        ttm2 <- travel_time_matrix(r5r_core = network,
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
      
      
      dow <- weekdays(departure_datetime,abbreviate = T)
      col_name <- paste0("hr_",hr,"_",dow)
      ttm2 <- ttm2 %>% select("fromId","toId","travel_time") %>% 
        rename(!!col_name := "travel_time")
      
      ttm1 <- ttm1 %>% full_join(ttm2,by = c("fromId" = "fromId", "toId" = "toId"))
      }
    }
  }
  
  
  
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
  ttm1[is.na(ttm1)] <- 120
  return(ttm)

}
