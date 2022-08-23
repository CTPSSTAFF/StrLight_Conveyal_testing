

source("./R_functions/census_data_prep.R")

# census data pull inputs
year_acs <- 2020
year_dec <- 2020
state <- c("MA","RI")

#download MBTA extended service area through MBTA Blue Book API
mbta_service_area <- read_sf("https://services1.arcgis.com/ceiitspzDAHrdGO1/arcgis/rest/services/MBTA_Extended_Service_Area/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
