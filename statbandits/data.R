library(tidyverse)
library(collections)

read_data <- function(type = "baseline"){
  
  sfx = ""
  
  if(type == "extended"){
    sfx = "ext"
  }
  
  pmap <- read_csv(paste0("pmap",sfx,".csv")) %>% mutate(id = as.factor(id))
  avgs <- read_csv(paste0("avgs",sfx,".csv")) %>% mutate(id = as.factor(id))
  sds <- read_csv(paste0("sds",sfx,".csv")) %>% mutate(id = as.factor(id))

  return(list("map" = pmap, "avgs" = avgs, "vars" = sds))
}

read_dictionaries <- function(){
  
  desc <- read_csv("dict.csv")
  
  pdict <- filter(desc, family == "param") 
  pdict <- dict(items = pdict$description, keys = pdict$name)
  rev_pdict <- pdict$keys()
  names(rev_pdict) <- as_vector(pdict$values())
  
  edict <- filter(desc, family == "endog") 
  edict <- dict(items = edict$description, keys = edict$name)
  rev_edict <- edict$keys()
  names(rev_edict) <- as_vector(edict$values())
  
  return(list("pdict" = pdict, "rev_pdict" = rev_pdict, "edict" = edict, "rev_edict" = rev_edict))
}

arrange_by <- function(vars, col){
  vars <- vars %>% mutate(new_col = (!!as.name(col))^2) %>% arrange(desc(new_col))
  return(vars)
}

pick_random <- function(tbl, max_ticks = 100, n_samples = 10){
  
  ids <- sample(as_vector(unique(tbl[,"id"])), n_samples)
  return(filter(tbl,id %in% ids, tick <= max_ticks))
}

pick_end_values <- function(tbl, inx, match_term){
  
  tbl %>% group_by(id) %>%
        mutate_at(vars(matches(match_term)),funs(nth(.,inx))) %>%
        select(matches(match_term),id) %>%
        distinct() %>%
        ungroup() %>%
        mutate(id = as.factor(id)) 
}

subset_per_level <- function(tbl, level, perc_rh = NULL){
  
  if(level == "Hierarchy"){
    tbl = filter(tbl, reached_hierarchy_mean >= perc_rh) 
  } else {
    tbl = filter(tbl, reached_hierarchy_mean == 0)
  }
  
  return(tbl)
}

join_with_tth <- function(tbl){
  
  tth <- read_csv("tth.csv") %>%
    mutate(id = as.factor(id)) %>%
    left_join(tbl, by="id") %>%
    replace(is.na(.), -1) %>%
    filter(reached_hierarchy_mean != -1) %>%
    select(id, time_to_hierarchy_mean) %>%
    group_by(id) %>%
    summarise_all(funs(mean,sd)) 
    
  names(tth)[2:3] <- c("time_to_hierarchy_mean", "time_to_hierarchy_sd")
  
  inner_join(tth, tbl, by="id")
}

select_by_params <- function(tbl, pmap, max_ticks, prod_adv, forg_inc, prop_bnd, perc_nof){
  
  sel = filter(pmap, foragers_income == forg_inc, prod_advantage == prod_adv, perc_non_farmers == perc_nof, prop_bandits == prop_bnd)
  
  n_id = as.integer(sel$id)
  return(filter(tbl, id == n_id, tick <= max_ticks))
}

select_by_id <- function(tbl, n_id, max_ticks){
  
  return(filter(tbl, id == n_id, tick <= max_ticks ))
}

reshape_vars <- function(tbl, pivots, cols){
  
   means <- paste0(cols, "_mean")
   sds <- paste0(cols, "_sd")
   
   #mat = sapply(cols,function(x){grep(x,names(tbl))})
   #means = names(tbl)[as_vector(mat[1,])]
   #sds = names(tbl)[as_vector(mat[2,])]
   
   sel1 = select(tbl, all_of(c(pivots, means)))
   sel2 = select(tbl, all_of(c(pivots, sds)))
   
   exp1 <- pivot_longer(sel1,-pivots, names_to = "name", values_to = "series_mean")
   exp2 <- pivot_longer(sel2,-pivots, names_to = "name", values_to = "series_sd")
   
   ret = bind_cols(exp1,tibble(exp2$series_sd))
   names(ret)[ncol(ret)] = "series_sd"
   
   return(ret)
}


get_al_xmin <- function(tbl){
  
  als <- filter(tbl, association_level_mean > 0) %>% select(association_level_mean)
  
  if(nrow(als) != 0){
    minVal <- min(als)
    return(min(which(tbl$association_level_mean == minVal)))
  } else {
    return(NULL)
  }
}


get_balanced_table <- function(tbl){
  
  cnts <- tbl %>% group_by(association_level) %>% count()
  nh <- as.integer(cnts[2,2])
  tbl_sample <- tbl %>% filter(association_level == 0) %>% slice_sample(n = nh)
  
  bind_rows(filter(tbl, association_level == 1), tbl_sample)
}