library(readr)
library(dplyr)
dir <- ".../.../statbandits/"

filename <- function(name){
  return(paste0(dir,name,".csv"))
}

joint <- read_csv("map_ext.csv")
joint <- select(joint, c("run","id"))

data <- read_csv("incomes_ext.csv")
names(data)[3:5] = c("pop_avg_income","farmers_avg_income","bandits_avg_income")
joint <- joint %>% inner_join(data, by="run") 

data <- read_csv("counts_ext.csv")
names(data)[3:4] = c("n_bandits","n_foragers")
joint <- joint %>% inner_join(data, by=c("run","tick")) 

data <- read_csv("parameters_ext.csv")
names(data)[3:4] = c("rate","beta")
joint <- joint %>% inner_join(data, by=c("run","tick"))

data <- read_csv("council_ext.csv")
names(data)[c(1:4,7)] = c("association_level","proposed_rate","bandits_votes","farmers_votes","security_tax")
joint <- joint %>% inner_join(data, by=c("run","tick"))

joint <- joint %>% replace(is.na(.), 0)

write_csv(joint,"all.csv")
.rs.restartR()
joint <- read_csv("all.csv")

tth <- joint %>% group_by(id,run)  %>%
                 mutate(time_to_hierarchy_mean = ifelse(association_level == 1, tick, 101)) %>% 
                 filter(time_to_hierarchy_mean == min(time_to_hierarchy_mean), time_to_hierarchy_mean != 101) %>%
                 select(id, time_to_hierarchy_mean)
  
prh <- tth %>% group_by(id) %>% 
               summarise(counts = n()) %>% 
               mutate(reached_hierarchy_mean = counts/30) %>%
               select(id,reached_hierarchy_mean) %>% 
               ungroup() %>%
               mutate(id = as.factor(id)) 


tth$time_to_hierarchy_mean = tth$time_to_hierarchy_mean - 1
write_csv(tth, filename("tth"))
tth <- NULL

joint <- joint %>% select(-run) %>%
                    group_by(id,tick) %>%
                    summarise_all(funs(mean,sd)) %>% 
                    ungroup() %>% 
                    mutate(id = as.factor(id)) %>%
                    left_join(prh, by="id") %>%
                    replace(is.na(.), 0)

write_csv(joint, filename("avgsext"))

pmap <- read_csv("map_ext.csv") %>% select(-c("randomSeed","population_size","run"))
names(pmap)[4] = "prop_bandits"
pmap <- pmap %>% distinct() %>% 
  mutate(id = as.factor(id), perc_bandits = prop_bandits*perc_non_farmers)

write_csv(pmap,filename("pmapext"))

by_variance = select(joint, contains("_mean"), "id") %>% group_by(id) %>% summarise_all(sd)
write_csv(by_variance, filename("sdsext"))

.rs.restartR()
all <- read_csv("all.csv")

tth <- all %>% group_by(run)  %>%
               mutate(time_to_hierarchy = ifelse(association_level == 1, tick, 101)) %>% 
               filter(time_to_hierarchy == min(time_to_hierarchy)) %>%
               select(run, time_to_hierarchy) %>%
               distinct()

all <- all %>%  group_by(run) %>%
                mutate_at(vars(-group_cols()), funs(nth(.,100))) %>%
                ungroup() %>%
                distinct() %>%
                select(-tick)

all <- all %>% inner_join(tth, by="run") %>% 
                inner_join(read_csv(filename("pmapext")), by="id")  %>% 
                mutate(diff_incomes = farmers_avg_income - bandits_avg_income)

write_csv(all, filename("docs/endvalsext"))
file.remove("all.csv")
