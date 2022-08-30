
cleanup_network <- function(network_dir){
  network_loc <- paste0(getwd(),"/Data/input/",network_dir)
  file_list <- list.files(network_loc, include.dirs = F, full.names = T, recursive = T)
  file.remove(file_list)
  paste0("network files removed from ",getwd(),"/Data/input/",network_dir)
}