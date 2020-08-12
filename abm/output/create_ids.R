library(tidyverse)

blob <- read_csv("map.csv")
# map2 <- read_csv("map_2.csv")
# nruns <- length(unique(map1$run))
# map2 <- mutate(map2, run = run + nruns)
# blob <- bind_rows(map1, map2)
#blob2 <- read_csv("incomes.2020.May.16.18_26_06.batch_param_map.csv")
#blob3 <- read_csv("counts.2020.May.16.18_26_06.batch_param_map.csv")
# identical(blob,blob2)
#blob = drop_na(blob)

iters = 30 
nConfigs = nrow(blob)/iters
tbList = vector(mode ="list", length = nConfigs)

## by(dataFrame, 1:nrow(dataFrame), function(row) dostuff)

for(i in 1:nConfigs){
  foragersIncome = as.numeric(blob[1,"foragers_income"])
  prodAdvantage = as.numeric(blob[1,"prod_advantage"])
  percNonFarmers = as.numeric(blob[1,"perc_non_farmers"])
  percBandits = as.numeric(blob[1,"perc_bandits"])
  
  filtered = blob %>% filter(foragers_income == foragersIncome & prod_advantage == prodAdvantage & perc_non_farmers == percNonFarmers & perc_bandits == percBandits)
  blob = blob %>% filter(!(foragers_income == foragersIncome & prod_advantage == prodAdvantage & perc_non_farmers == percNonFarmers & perc_bandits == percBandits))
  tbList[[i]] = bind_cols(filtered, as_tibble(rep(i,iters)))
}

blob = bind_rows(tbList)
names(blob)[ncol(blob)] = "id"
write_csv(blob,"map_ext.csv")


# map1 <- read_csv("counts_1.csv")
# map2 <- read_csv("counts_2.csv")
# map2 <- mutate(map2, run = run + nruns)
# write_csv(bind_rows(map1, map2),"counts.csv")

