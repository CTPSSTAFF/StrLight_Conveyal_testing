library(rJava)
sys_memory <- "50000" #system memory in MB to allocate to Java
java_ram <- paste0("-Xmx",sys_memory,"m")
options(java.parameters = java_ram)
rJava::.jinit(force.init=TRUE)


source("./R_functions/OD_point_functions.R")
source("./Analysis/Build_network.R")
source("./Analysis/Cleanup_network_files.R")
source("./Analysis/Transit_routing_r5r.R")


baseline_gtfs <- "gtfs_base_031522_v2"
proposed_gtfs <- "gtfs_bnrd_041922_v2"

od_points <- create_od_points(state=c("MA","RI"), year=2020) #need to update to join TAZ GEOIDs to points and remove any that are not in a taz
od_points <- st_read("Data/Processed/od_points.shp")


base_network <- build_network(network_dir="Base_network",gtfs="gtfs_base_031522_v2",sys_memory=sys_memory)
cleanup_network(network_dir="Base_network")
base_matrix <- route_between_points(network=base_network,od_points=od_points)

prop_network <- build_network(network_dir="Prop_network",gtfs="gtfs_bnrd_041922_v2",sys_memory=sys_memory)
cleanup_network(network_dir="Prop_network")
prop_matrix <- route_between_points(network=prop_network,od_points=od_points)



base_matrix <- readRDS("Data/Processed/base_matrix.rds")
prop_matrix <- readRDS("Data/Processed/prop_matrix.rds")

#join taz GEOIDS to points
od_points <- st_read("Data/Processed/od_points.shp")
taz_ri <- st_read("Data/TAZ/tl_2011_44_taz10/tl_2011_44_taz10.shp")
taz_ma <- st_read("Data/TAZ/tl_2011_25_taz10/tl_2011_25_taz10.shp")
taz <- rbind(taz_ri,taz_ma) %>% st_transform(crs=4326)

od_taz = st_join(od_points, taz, join = st_intersects) %>% 
  select(id,GEOID10) %>% 
  drop_na(GEOID10) %>% 
  mutate(id = as.character(id))
od_taz_nogeo <- as_tibble(od_taz) %>% select(id,GEOID10)

base_matrix <- base_matrix %>% left_join(od_taz,by = c("fromId" = "id")) %>% 
  rename("fromGEOID" = "GEOID10")

base_matrix <- base_matrix %>% left_join(od_taz_nogeo,by = c("toId" = "id")) %>% 
  rename("toGEOID" = "GEOID10")

base_matrix <- base_matrix %>% drop_na(fromGEOID,toGEOID)

#filter out travel from and to the same taz
base_matrix <- base_matrix %>% filter(fromGEOID != toGEOID)
base_matrix_mean <- base_matrix %>% group_by(fromGEOID,toGEOID) %>% 
  summarize(mean_travel_time =mean(travel_time))# summarize mean travel time between TAZ pairs


prop_matrix <- prop_matrix %>% left_join(od_taz,by = c("fromId" = "id")) %>% 
  rename("fromGEOID" = "GEOID10")

prop_matrix <- prop_matrix %>% left_join(od_taz_nogeo,by = c("toId" = "id")) %>% 
  rename("toGEOID" = "GEOID10")

prop_matrix <- prop_matrix %>% drop_na(fromGEOID,toGEOID)

#filter out travel from and to the same taz
prop_matrix <- prop_matrix %>% filter(fromGEOID != toGEOID)
prop_matrix_mean <- prop_matrix %>% group_by(fromGEOID,toGEOID) %>% 
  summarize(mean_travel_time = mean(travel_time))# summarize mean travel time between TAZ pairs


# StreetLight_processing.R
od_inc_r <- readRDS("Data/input/SL/sl_od_inc.rds")
od_race_r <- readRDS("Data/input/SL/sl_od_race.rds")

od_inc_wkdy_2pm <- od_inc_r %>% filter(dow == "1: Weekday (M-F)",
                                     time == "15: 2pm (2pm-3pm)")
# all_day <- od_inc %>% filter(dow == "0: All Days (M-Su)",
#                                      time == "00: All Day (12am-12am)")

od_inc_wkdy_2pm <- od_inc_wkdy_2pm %>% mutate_at(c('origin_id','dest_id'),as.character)

base_matrix_od2pm <- od_inc_wkdy_2pm %>% left_join(base_matrix_mean,by = c("origin_id" = "fromGEOID", "dest_id" = "toGEOID"))

base_matrix_od2pm <- base_matrix_od2pm %>% mutate(li_trip_mins = (pct_low_income * trips)*mean_travel_time,
                                                  nli_trip_mins = (pct_non_low_income * trips)*mean_travel_time)
base_li_trip_mins <- sum(base_matrix_od2pm$li_trip_mins,na.rm = T)
base_nli_trip_mins <- sum(base_matrix_od2pm$nli_trip_mins,na.rm = T)


prop_matrix_od2pm <- od_inc_wkdy_2pm %>% left_join(prop_matrix_mean,by = c("origin_id" = "fromGEOID", "dest_id" = "toGEOID"))

prop_matrix_od2pm <- prop_matrix_od2pm %>% mutate(li_trip_mins = (pct_low_income * trips)*mean_travel_time,
                                                  nli_trip_mins = (pct_non_low_income * trips)*mean_travel_time)
prop_li_trip_mins <- sum(prop_matrix_od2pm$li_trip_mins,na.rm = T)
prop_nli_trip_mins <- sum(prop_matrix_od2pm$nli_trip_mins,na.rm = T)

# didb relative ratio
((base_li_trip_mins - prop_li_trip_mins)/base_li_trip_mins)/((base_nli_trip_mins - prop_nli_trip_mins)/base_nli_trip_mins)




