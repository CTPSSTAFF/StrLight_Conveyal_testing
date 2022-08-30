#for reference: https://walker-data.com/tidycensus/articles/basic-usage.html

library(tidycensus)
library(tidyverse)
library(sf)
library(tigris)

library(geojsonsf)
library(reticulate)

options(tigris_use_cache = TRUE)


create_od_points <- function(state, year){
  
  # MBTA service area
  #mbta_service_area <- read_sf("https://services1.arcgis.com/ceiitspzDAHrdGO1/arcgis/rest/services/MBTA_Extended_Service_Area/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
  #st_write(mbta_service_area,"Data/input/mbta_service_area.geojson") #need to change to a buffer around stations

  
  #get list of counties in states
  counties <- list()
  for (i in 1:length(state)){
    state_i <- state[i]
    counties_i <- counties(state_i) %>% 
      st_drop_geometry() %>% 
      select(GEOID,STATEFP, COUNTYFP)
    counties[[i]] <- counties_i
  }
  counties <-bind_rows(counties) 
  
  #get water by county
  all_water <- list()
  for (i in 1:nrow(counties)){
    water_i <- area_water(counties$STATEFP[[i]], counties$COUNTYFP[[i]], year= year) %>% 
      mutate(GEOID_county= counties$GEOID[[i]])
    all_water[[i]]<- water_i
  }
  all_water <- bind_rows(all_water) %>% st_as_sf()
  st_write(all_water,"Data/input/water_ma_ri.geojson",append=FALSE)
  
  #get roads for both states
  ma_roads <- get_roads_for_state(state="MA", year=year)
  ri_roads <- get_roads_for_state(state="RI", year=year)
  ma_ri_roads <- rbind(ma_roads,ri_roads)
  st_write(ma_ri_roads,"Data/input/roads_ma_ri.geojson",append=FALSE)
  
  use_condaenv(condaenv  = "Py_env/",required = TRUE)# "/" locates the correct location and "required = TRUE" forces reticulate to use this version
  source_python("Py_functions/OD_point_generator.py")
  source_python("Py_functions/point_water_road_filter.py")
  
  generate_fishnet(working_dir=getwd())
  filter_fishnet(working_dir=getwd())
  fishnet <- geojson_sf("Data/Processed/filtered_fishnet.geojson") %>%  st_set_crs(4326)
  #tracts_water_pct <- tracts_water_pct %>% select(GEOID, orig_m2, land_ratio, geometry)
  
  
  generate_taz_centroids(working_dir=getwd())
  rep_points <- geojson_sf("Data/Processed/taz_rep_point.geojson") %>%  st_set_crs(4326)
  
  od_points <- rbind(fishnet,rep_points)
  od_points <- od_points %>% mutate(id=1:nrow(od_points))
  od_points <- od_points %>%
    mutate(long = unlist(map(od_points$geometry,1)),
           lat = unlist(map(od_points$geometry,2))) %>% 
    select(id,geometry,lat,long)
  
  write_sf(od_points,"Data/Processed/od_points.shp")
  
  #tracts_nowater <- st_erase(tracts, all_water)
  #tracts_nowater$land_area_sqmeter <- units::drop_units(st_area(tracts_nowater))
  #tracts_geog<- tracts_nowater %>% 
  #  select(GEOID, land_area_sqmeter)
  #write_rds(tracts_water_pct, "data/processed/tracts_water_ratio_MaRi.rds")  
  #file.remove("Data/input/roads_ma_ri.geojson")
  #file.remove("Data/input/water_ma_ri.geojson")
  #file.remove("Data/input/mbta_service_area.geojson")
  return(od_points)
  
}

get_roads_for_state <- function(state, year){
  counties<- counties(state) %>% st_drop_geometry()
  if (state == "MA"){
    counties <- counties %>% filter(NAME == "Suffolk"|
                                            NAME == "Norfolk"|
                                            NAME == "Middlesex"|
                                            NAME == "Worcester"|
                                            NAME == "Essex"|
                                            NAME == "Plymouth"|
                                            NAME == "Bristol")
  }
  if (state == "RI"){
    counties <- counties %>% filter(NAME == "Providence"|
                                      NAME == "Bristol"|
                                      NAME == "Washington"|
                                      NAME == "Kent")
  }
  roads <- rbind_tigris(
    lapply(counties$NAME, function(x){
      roads(state, x, year= year)})
  )
}

