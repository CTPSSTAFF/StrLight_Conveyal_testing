library(tidyverse)

#od_all <- read.csv("F:/Shared drives/Transit_Analysis_Planning/MBTA DI DB Policy Update/Metrics_testing/Data/StreetLight_1113415_Title_VI_DI_DB_Metrics_Test/1113415_Title_VI_DI_DB_Metrics_Test_od_all.csv")
od_inc <- read.csv("F:/Shared drives/Transit_Analysis_Planning/MBTA DI DB Policy Update/Metrics_testing/Data/StreetLight_1113415_Title_VI_DI_DB_Metrics_Test/1113415_Title_VI_DI_DB_Metrics_Test_od_traveler_education_income_all.csv")
od_race <- read.csv("F:/Shared drives/Transit_Analysis_Planning/MBTA DI DB Policy Update/Metrics_testing/Data/StreetLight_1113415_Title_VI_DI_DB_Metrics_Test/1113415_Title_VI_DI_DB_Metrics_Test_od_traveler_equity_all.csv")


#od_all_r <- od_all %>% select(Origin.Zone.Name,
#                              Destination.Zone.Name,
#                              Day.Type,
#                              Day.Part,
#                              Average.Daily.O.D.Traffic..StL.Volume.)


od_inc_r <- od_inc %>% select(Origin.Zone.Name,
                              Destination.Zone.Name,
                              Day.Type,
                              Day.Part,
                              Income.Less.than.10K,                  
                              Income.10K.to.15K,                     
                              Income.15K.to.20K,                    
                              Income.20K.to.25K,                    
                              Income.25K.to.30K,                     
                              Income.30K.to.35K,                      
                              Income.35K.to.40K,                    
                              Income.40K.to.45K,                    
                              Income.45K.to.50K,                      
                              Income.50K.to.60K,                    
                              Income.60K.to.75K,                   
                              Income.75K.to.100K,                    
                              Income.100K.to.125K,                  
                              Income.125K.to.150K,                   
                              Income.150K.to.200K,                 
                              Income.More.than.200K,
                              Average.Daily.O.D.Traffic..StL.Volume.) %>% 
  mutate_at(c('Income.Less.than.10K',                  
                            'Income.10K.to.15K',                     
                            'Income.15K.to.20K',                    
                            'Income.20K.to.25K',                    
                            'Income.25K.to.30K',                     
                            'Income.30K.to.35K',                      
                            'Income.35K.to.40K',                    
                            'Income.40K.to.45K',                    
                            'Income.45K.to.50K',                      
                            'Income.50K.to.60K',                    
                            'Income.60K.to.75K',                   
                            'Income.75K.to.100K',                    
                            'Income.100K.to.125K',                  
                            'Income.125K.to.150K',                   
                            'Income.150K.to.200K',                 
                            'Income.More.than.200K'),as.numeric) %>% 
  mutate(Less_than_50K = Income.Less.than.10K+                  
                             Income.10K.to.15K+                   
                             Income.15K.to.20K+                    
                             Income.20K.to.25K+                    
                             Income.25K.to.30K+                     
                             Income.30K.to.35K+                      
                             Income.35K.to.40K+                   
                             Income.40K.to.45K+                   
                             Income.45K.to.50K) %>% 
  mutate(Greater_than_60K = Income.60K.to.75K+                   
                             Income.75K.to.100K+                   
                             Income.100K.to.125K+                 
                             Income.125K.to.150K+                
                             Income.150K.to.200K+               
                             Income.More.than.200K) 

# create low income and non low income groups and split 50 to 60k $55339.7

low_income_threshold <- 55339.7
pct_split_to_li <- (low_income_threshold - 50000)/10000
pct_split_to_nli <- (60000 - low_income_threshold)/10000
od_inc_r <- od_inc_r %>% mutate(Less_than_lit = Income.50K.to.60K*pct_split_to_li,
                    More_than_lit = Income.50K.to.60K*pct_split_to_nli,
                    pct_low_income = Less_than_50K + Less_than_lit,
                    pct_non_low_income = More_than_lit + Greater_than_60K) %>% 
  select(Origin.Zone.Name,
         Destination.Zone.Name,
         Day.Type,
         Day.Part,
         Average.Daily.O.D.Traffic..StL.Volume.,
         pct_low_income,
         pct_non_low_income) %>% 
  rename(origin_id = Origin.Zone.Name,
         dest_id = Destination.Zone.Name,
         dow = Day.Type,
         time = Day.Part,
         trips = Average.Daily.O.D.Traffic..StL.Volume.)

od_inc_r <- od_inc_r %>% mutate_at('trips',as.numeric) %>% 
  mutate_at(c('origin_id','dest_id'),as.character)

od_inc_r <- od_inc_r %>% filter(origin_id != dest_id)



od_race_r <- od_race  %>% 
  mutate(minority = Black +
                    American.Indian +
                    Asian +                               
                    Pacific.Islander +
                    Other.Race +
                    Multiple.Races,
         non_minority = White) %>% 
  select(Origin.Zone.Name,
         Destination.Zone.Name,
         Day.Type,
         Day.Part,
         minority,                                 
         non_minority,
         Average.Daily.O.D.Traffic..StL.Volume.) %>%
  rename(origin_id = Origin.Zone.Name,
         dest_id = Destination.Zone.Name,
         dow = Day.Type,
         time = Day.Part,
         trips = Average.Daily.O.D.Traffic..StL.Volume.)

od_race_r <- od_race_r %>% mutate_at('trips',as.numeric) %>% 
  mutate_at(c('origin_id','dest_id'),as.character)

od_race_r <- od_race_r %>% filter(origin_id != dest_id)

#saveRDS(od_all_r,"Data/input/SL/sl_od_all.rds")
saveRDS(od_inc_r,"Data/input/SL/sl_od_inc.rds")
saveRDS(od_race_r,"Data/input/SL/sl_od_race.rds")

