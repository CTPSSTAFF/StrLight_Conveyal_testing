library(tidyverse)
library(sf)

join_and_process <- function(taz,od_points,matrix,streetlight,demographic)


od_points <- st_read("Data/Processed/od_points.shp")
taz_ri <- st_read("Data/TAZ/tl_2011_44_taz10/tl_2011_44_taz10.shp")
taz_ma <- st_read("Data/TAZ/tl_2011_25_taz10/tl_2011_25_taz10.shp")
taz <- rbind(taz_ri,taz_ma) %>% st_transform(crs=4326)

od_taz = st_join(od_points, taz, join = st_intersects) %>% 
  select(id,GEOID10) %>% 
  drop_na(GEOID10) %>% 
  mutate(id = as.character(id))
od_taz_nogeo <- as_tibble(od_taz) %>% select(id,GEOID10)

matrix <- matrix %>% left_join(od_taz,by = c("fromId" = "id")) %>% 
  rename("fromGEOID" = "GEOID10") %>%
  left_join(od_taz_nogeo,by = c("toId" = "id")) %>% 
  rename("toGEOID" = "GEOID10") %>% 
  drop_na(fromGEOID,toGEOID)

#filter out travel from and to the same taz
mean_matrix <- matrix %>% filter(fromGEOID != toGEOID) %>% 
  group_by(fromGEOID,toGEOID) %>% 
  summarize(mean_travel_time = mean(travel_time))# summarize mean travel time between TAZ pairs
