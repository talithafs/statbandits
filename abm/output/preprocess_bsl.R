library(readr)
library(dplyr)
dir <- ".../.../statbandits/"

filename <- function(name){
  return(paste0(dir,name,".csv"))
}

#library(Hmisc)

pmap <- read_csv("map.csv")
incomes <- read_csv("incomes.csv")
counts <- read_csv("counts.csv")
params <- read_csv("parameters.csv")

#popSize <- as.numeric(pmap[1,"population_size"])
pmap <- select(pmap, c("run","id"))

incomes = incomes %>% replace(is.na(.), 0)
params = params %>% replace(is.na(.), 0)

names(incomes)[3:5] = c("pop_avg_income","farmers_avg_income","bandits_avg_income")
names(params)[3:4] = c("rate","beta")
names(counts)[3:4] = c("n_bandits","n_foragers")

joint <- pmap %>% inner_join(incomes, by="run")%>% 
  inner_join(counts, by=c("run","tick")) %>% 
  inner_join(params, by=c("run","tick"))

joint <- joint %>% group_by(id,tick) %>%
  summarise_at(vars(-names(pmap)[1]),funs(mean,sd)) %>% 
  ungroup() %>% mutate(id = as.factor(id))

pmap <- read_csv("map.csv") %>% select(-c("randomSeed","population_size"))
names(pmap)[5] = "prop_bandits"
#vec_ids = as_vector(unique(avgs[,"id"]))
pmap <- pmap %>% select(-run) %>% distinct()  %>% 
  mutate(id = as.factor(id), perc_bandits = prop_bandits*perc_non_farmers)

write_csv(joint,filename("avgs"))
write_csv(pmap,filename("pmap"))

# desc_avgs <- Hmisc::describe(avgs)
# desc_pmap <- Hmisc::describe(pmap)
# 
# save(desc_avgs, file = "desc_avgs.RData")
# save(desc_pmap, file = "desc_pmap.RData")

by_variance = select(joint, contains("_mean"), "id") %>% group_by(id) %>% summarise_all(sd)
write_csv(by_variance, filename("sds"))
  