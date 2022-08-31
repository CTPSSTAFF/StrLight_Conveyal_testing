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

od_points <- create_od_points(state=c("MA","RI"), year=2020)
#od_points <- readRDS("C:/Users/bbact/Documents/od_points.rds")


base_network <- build_network(network_dir="Base_network",gtfs="gtfs_base_031522_v2",sys_memory=sys_memory)
cleanup_network(network_dir="Base_network")
base_matrix <- route_between_points(network=base_network,od_points=od_points, sys_memory=sys_memory)

prop_network <- build_network(network_dir="Prop_network",gtfs="gtfs_bnrd_041922_v2",sys_memory=sys_memory)
cleanup_network(network_dir="Prop_network")
prop_matrix <- route_between_points(network=prop_network,od_points=od_points, sys_memory=sys_memory)

#next steps

#filter out travel from and to the same taz

base_matrix <- base_matrix %>% filter(fromId != toId)
prop_matrix <- prop_matrix %>% filter(fromId != toId)

matrix_mean <- base_matrix %>% group_by(fromId,toId) %>% 
  summarize(mean(travel_time))

 # base_matrix %>% mutate(same_taz = case_when(
#   fromId == toId ~ 1,
#   TRUE ~ 0
# ))
