library(r5r)
library(tidyverse)
library(sf)
library(tictoc)
library(osmextract)
#library(rJava)


build_network <- function(sys_memory,network_dir,gtfs){
  #java_ram <- paste0("-Xmx",sys_memory,"G")
  #options(java.parameters = java_ram)
  #rJava::.jinit()
  
  gtfs_loc <- file.path(getwd(),paste0("Data/input/GTFS/",gtfs,".zip"))
  net_loc <- file.path(getwd(),paste0("Data/input/",network_dir),paste0(gtfs,".zip"))
  file.copy(from = gtfs_loc, to = net_loc, overwrite = TRUE)
  
  oe_get("us/rhode-island",provider = "geofabrik")
  pbf_name <- paste0("geofabrik_",tail(strsplit(oe_match("us/rhode-island",provider = "geofabrik")$url,split="/")[[1]],n=1))
  temp_loc <- file.path(tempdir(),pbf_name)
  proj_loc <- file.path(getwd(),paste0("Data/input/",network_dir),pbf_name)
  file.copy(from = temp_loc, to = proj_loc, overwrite = TRUE)
  file.remove(temp_loc)
  
  oe_get("us/massachusetts",provider = "geofabrik")
  pbf_name <- paste0("geofabrik_",tail(strsplit(oe_match("us/massachusetts",provider = "geofabrik")$url,split="/")[[1]],n=1))
  temp_loc <- file.path(tempdir(),pbf_name)
  proj_loc <- file.path(getwd(),paste0("Data/input/",network_dir),pbf_name)
  file.copy(from = temp_loc, to = proj_loc, overwrite = TRUE)
  file.remove(temp_loc)
  
  r5r_network <- setup_r5(data_path = paste0("Data/input/",network_dir), verbose = F)
  return(r5r_network)
  
}