#for reference: https://walker-data.com/tidycensus/articles/basic-usage.html

library(tidycensus)
library(tidyverse)
library(sf)
library(tigris)

library(geojsonsf)
library(reticulate)

options(tigris_use_cache = TRUE)



get_low_inc_threshold <- function(year_acs, state="MA", service_area = mbta_service_area, percent= .6){
  
  
  # Household income distribution by county sub_division
  inc_variables <- paste0("B19001_", str_pad(c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17), width = 3, side = "left", pad = 0))
  inc_ranges <- c( "TotHH","<10k","10k_15k","15k_20K","20k_25k","25k_30k","30k_35k","35k_40k","40k_45k",
                   "45k_50k","50k_60k","60k_75k","75k_100k","100k_125k","125k_150k","150k_200k",">200k")
  
  
  income_dist_raw <- get_acs(geography = "county subdivision",
                             variables = inc_variables,
                             # summary_var = inc_summary_var,
                             state = state,
                             geometry = T,
                             cb= T,
                             year = year_acs) 
  
  # from state, pull only towns in service area
  inc_dist_state<- income_dist_raw %>% st_transform(26986)
  inc_dist_service_area <-inc_dist_state[sf::st_centroid(st_transform(service_area, 26986)),]
  
  inc_dist <- inc_dist_service_area %>% 
    st_drop_geometry() %>% 
    left_join(tibble(variable = inc_variables, inc_range = inc_ranges), by= "variable") %>% 
    rename(estimate_hh = estimate, 
           moe_hh = moe #,
           # est_tot_hh = summary_est,
           # moe_tot_hh = summary_moe
    ) %>% 
    select(GEOID, NAME, inc_range, estimate_hh) %>% 
    pivot_wider(names_from = inc_range, values_from = estimate_hh) %>% 
    janitor::adorn_totals() 
  
  inc<- c( "<10k","10k_15k","15k_20K","20k_25k","25k_30k","30k_35k","35k_40k","40k_45k",
           "45k_50k","50k_60k","60k_75k","75k_100k","100k_125k","125k_150k","150k_200k",">200k")
  inc_low <- c(0, 10000, 15000, 20000, 25000, 30000,35000, 40000,45000, 50000, 60000, 75000, 100000, 125000, 150000, 200000)
  inc_high <- c(9999, 14999, 19999, 24999, 29999, 34999, 39999, 44999, 49999, 59999, 74999,99999, 124999, 149999, 199999, 999999)
  
  totals <- inc_dist[inc_dist$GEOID == "Total",] %>% 
    select(-c(GEOID, NAME)) %>% 
    pivot_longer(cols= -TotHH,names_to = "inc", values_to = "hh" ) %>% 
    mutate(perc_hh_sa= hh/TotHH*100) %>% 
    mutate(cumsum = cumsum(perc_hh_sa)) %>% 
    left_join(tibble(inc= inc, inc_low=inc_low, inc_high= inc_high), by="inc") %>% 
    mutate(med_calc = ifelse(cumsum >= 50 & lag(cumsum <50),
                             round(inc_low+(inc_high-inc_low)*(50-lag(cumsum))/(cumsum-lag(cumsum)),2),
                             0))
  
  median_income_service_area <-totals$med_calc[which(totals$med_calc!=0)]
  low_inc_threshold <- round(median_income_service_area*percent,2)
  return(low_inc_threshold)
}

get_census_tract_inc_status_data <- function(year_acs, year_dec, state, low_income_threshold){
  
  # acs_vars <- load_variables(year_acs, "acs5", cache = TRUE)
  # dec_vars <- load_variables(year_dec, "pl", cache = TRUE)
  
  ##### Income distribution #####
  
  # Household income distribution by census tract
  inc_variables <- paste0("B19001_", str_pad(c(2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17), width = 3, side = "left", pad = 0))
  inc_ranges <- c( "<10k","10k_15k","15k_20K","20k_25k","25k_30k","30k_35k","35k_40k","40k_45k",
                   "45k_50k","50k_60k","60k_75k","75k_100k","100k_125k","125k_150k","150k_200k",">200k")
  inc_low <- c(0, 10000, 15000, 20000, 25000, 30000,35000, 40000,45000, 50000, 60000, 75000, 100000, 125000, 150000, 200000)
  inc_high <- c(9999, 14999, 19999, 24999, 29999, 34999, 39999, 44999, 49999, 59999, 74999,99999, 124999, 149999, 199999, 999999)
  inc_summary_var <- "B19001_001"
  
  
  income_dist_raw_acs <- get_acs(geography = "tract",
                                 variables = inc_variables,
                                 summary_var = inc_summary_var,
                                 state = state,
                                 geometry = F,
                                 cb= F,
                                 year = year_acs) 
  
  
  inc_dist_acs <- income_dist_raw_acs %>% 
    left_join(tibble(variable = inc_variables, inc_range = inc_ranges), by= "variable") %>% 
    left_join(tibble(inc_range= inc_ranges, inc_low= inc_low, inc_high= inc_high),by = "inc_range") %>% 
    mutate(inc_status = case_when(
      inc_high <= low_income_threshold~ "lowincome",
      inc_low > low_income_threshold ~ "nonlowincome",
      TRUE ~ "split"))
  
  split <- inc_dist_acs %>% 
    filter(inc_status== "split") %>% 
    mutate(estimate_low = (low_income_threshold-inc_low)/(inc_high-inc_low)*estimate,
           estimate_high= estimate- estimate_low) %>% 
    pivot_longer(cols= c(estimate_low, estimate_high)) %>%
    mutate(inc_status= ifelse(name=="estimate_low", "lowincome", "nonlowincome")) %>% 
    select(-estimate) %>% 
    rename(estimate= value)
  
  inc_status_acs <- inc_dist_acs %>% 
    filter(inc_status != "split") %>% 
    bind_rows(split) %>% 
    group_by(GEOID, inc_status) %>% 
    summarize(est=sum(estimate),
              est_moe= moe_sum(moe,estimate),
              pop_acs= first(summary_est),
              pop_acs_moe= first(summary_moe)) %>%
    group_by(GEOID, inc_status) %>% 
    summarize(percent= est/pop_acs,
              percent_moe= moe_prop(est, pop_acs, est_moe, pop_acs_moe)) %>% 
    pivot_wider(names_from= inc_status, values_from = c(percent, percent_moe))
  
  
  
  
  # get population from decennial
  dec_raw <- get_decennial(geography = "tract",
                           variables= "H1_001N", # total occupied housing units
                           state = state,
                           geometry = FALSE,
                           year = year_dec)
  
  # Bring income acs and dec together ########
  income_status <- dec_raw %>% 
    select(-variable) %>% 
    rename(pop_dec= value) %>% 
    left_join(inc_status_acs, by = "GEOID") %>% 
    mutate(lowincome= pop_dec*percent_lowincome,
           nonlowincome = pop_dec*percent_nonlowincome)
  
  return(income_status)
}

get_census_tract_min_status_data <- function(year_acs, year_dec, state){
  # acs_vars <- load_variables(year_acs, "acs5", cache = TRUE)
  # dec_vars <- load_variables(year_dec, "sf1", cache = TRUE)
  #####  Minority ( non-Hispanic white) #####
  
  race_variables_acs <- paste0("B03002_", str_pad(c(3:9,12), width = 3, side = "left", pad = 0))
  # race_variables_acs_desc <- c( "nhisp_wht", rep("nhisp_nwht", 6), "hisp")
  race_variables_aces_min_stat <- c("nonmin", rep("min",7))
  
  race_acs_raw <- get_acs(geography = "tract",
                          variables = race_variables_acs,
                          summary_var = "B03002_001",
                          state= state,
                          geometry = F,
                          year= year_acs) %>% 
    left_join(tibble(variable = race_variables_acs,
                     min_status = race_variables_aces_min_stat),by = "variable")
  
  race_acs <- race_acs_raw %>%
    group_by(GEOID, min_status) %>% 
    summarize(est=sum(estimate),
              est_moe= moe_sum(moe,estimate),
              pop_acs= first(summary_est),
              pop_acs_moe= first(summary_moe)) %>%
    group_by(GEOID, min_status) %>% 
    summarize(percent= est/pop_acs,
              percent_moe= moe_prop(est, pop_acs, est_moe, pop_acs_moe)) %>% 
    pivot_wider(names_from= min_status, values_from = c(percent, percent_moe))
  
  #get population from decennial
  dec_raw <- get_decennial(geography = "tract",
                           variables = "P1_001N",  # total population by race
                           state = state,
                           geometry = FALSE,
                           year = year_dec)
  
  # Bring race acs and dec together ########
  minority_status <- dec_raw %>% 
    select(-variable) %>% 
    rename(pop_dec= value) %>% 
    left_join(race_acs, by = "GEOID") %>% 
    mutate(minority= pop_dec*percent_min,
           nonminority = pop_dec*percent_nonmin)
  return(minority_status)
  
}

st_erase <- function(x, y) {
  st_difference(x, st_union(y))
}

filter_od_points <- function(state, year_acs){
  
  # MBTA service area
  mbta_service_area <- read_sf("https://services1.arcgis.com/ceiitspzDAHrdGO1/arcgis/rest/services/MBTA_Extended_Service_Area/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
  st_write(mbta_service_area,"Data/input/mbta_service_area.geojson")

  
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
    water_i <- area_water(counties$STATEFP[[i]], counties$COUNTYFP[[i]], year= year_acs) %>% 
      mutate(GEOID_county= counties$GEOID[[i]])
    all_water[[i]]<- water_i
  }
  all_water <- bind_rows(all_water) %>% st_as_sf()
  st_write(all_water,"Data/input/water_ma_ri.geojson")
  
  
  ma_roads <- get_roads_for_state(state="MA", year=year_acs)
  ri_roads <- get_roads_for_state(state="RI", year=year_acs)
  ma_ri_roads <- rbind(ma_roads,ri_roads)
  st_write(ma_ri_roads,"Data/input/roads_ma_ri.geojson",append=FALSE)
  
  use_condaenv(condaenv  = "Py_env/",required = TRUE)# "/" locates the correct location and "required = TRUE" forces reticulate to use this version
  source_python("Py_functions/tract_water_slicer.py")
  tract_water_slicer(working_dir = getwd())
  
  
  tracts_water_pct <- geojson_sf("data/processed/tracts_no_water.geojson") %>%  st_set_crs(4269)
  tracts_water_pct <- tracts_water_pct %>% select(GEOID, orig_m2, land_ratio, geometry)
  
  
  #tracts_nowater <- st_erase(tracts, all_water)
  #tracts_nowater$land_area_sqmeter <- units::drop_units(st_area(tracts_nowater))
  #tracts_geog<- tracts_nowater %>% 
  #  select(GEOID, land_area_sqmeter)
  write_rds(tracts_water_pct, "data/processed/tracts_water_ratio_MaRi.rds")  
  return(tracts_water_pct)
  
}

get_roads_for_state <- function(state, year_acs){
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
                                              NAME == "Washington")
  }
  ri_roads <- rbind_tigris(
    lapply(counties$NAME, function(x){
      roads(state, x, year= year_acs)
    })
  )
}

get_road_length_by_geoid <- function (roads, census_geog) {
  st_collection_extract(st_intersection(roads, census_geog), "LINESTRING")%>% 
    mutate(len_m = sf::st_length(geometry)) %>%
    st_drop_geometry() %>% 
    group_by(GEOID) %>% 
    summarize(len_m = sum(len_m))
}

intersect_service_area_w_tract_and_summarize<- function(census_tract_demographics_select, service_area, type){# roads removed from function
  int_wtracts <- st_intersection(census_tract_demographics_select,st_transform(service_area,4269)) %>%
    st_as_sf() %>% 
    mutate(land_area_sqmeter_int= units::drop_units(st_area(geometry))) %>% 
    mutate(portion_tract_land = land_area_sqmeter_int/orig_m2)
  
  
  # ma_roads_by_geoid_current_int <- get_road_length_by_geoid(road_inv_select_proj, current_int_wtracts)
  # road_length_by_geoid_current_int <- bind_rows(ri_roads_by_geoid_current_int, ma_roads_by_geoid_current_int) %>% 
  #roads_by_geoid_int <- get_road_length_by_geoid(roads, int_wtracts) %>% 
  #  rename(int_road_len_m = len_m)
  
  int_wtracts <- int_wtracts %>% 
    #left_join(roads_by_geoid_int) %>% 
    #mutate(portion_tract_road = units::drop_units(int_road_len_m)/units::drop_units(len_m)) %>% 
    select(GEOID, starts_with("portion"), tract_lowincome= lowincome, tract_nonlowincome= nonlowincome, 
           tract_minority= minority, tract_nonminority= nonminority,portion_tract_land)
  int_totals_geog<- int_wtracts %>% 
    mutate(land_lowincome= tract_lowincome*portion_tract_land,
           land_nonlowincome= tract_nonlowincome*portion_tract_land,
           land_minority = tract_minority*portion_tract_land,
           land_nonminority= tract_nonminority*portion_tract_land,
           #road_lowincome= tract_lowincome*portion_tract_road,
           #road_nonlowincome= tract_nonlowincome*portion_tract_road,
           #road_minority = tract_minority*portion_tract_road,
           #road_nonminority= tract_nonminority*portion_tract_road
           )
  int_totals <- int_totals_geog %>% 
    st_drop_geometry() %>% 
    summarise(land_lowincome= sum(land_lowincome, na.rm= T),
              land_nonlowincome= sum(land_nonlowincome, na.rm= T),
              land_minority = sum(land_minority, na.rm= T),
              land_nonminority= sum(land_nonminority, na.rm= T),
              #road_lowincome= sum(road_lowincome, na.rm= T),
              #road_nonlowincome= sum(road_nonlowincome, na.rm= T),
              #road_minority = sum(road_minority, na.rm= T),
              #road_nonminority= sum(road_nonminority, na.rm= T)
              ) %>% 
    mutate(type= type)
  
  result <- list()
  result[[1]]<- int_totals_geog
  result[[2]]<- int_totals
  
  # We only need the totals
  out <- result[[2]]
  
  return(out)
  
}
