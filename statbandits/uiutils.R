library(shiny)
library(shinydashboard)

createSlider <- function(pmap, pdict, slider_name, param_name){
  
  vec = as_vector(pmap[,param_name])
  vec = unique(vec[order(vec)])
  s = vec[2] - vec[1]
  
  return(sliderInput(slider_name, pdict$get(param_name), min(vec), max(vec), min(vec), step = s, animate =
                       animationOptions(interval = 2000, loop = FALSE)))
}

createDropdown <- function(rdict, dd_name, param_name, selc, type = "baseline"){
  
  if(type == "baseline"){
    vars = as_vector(rdict)
    ext_vars = c("security_tax", "association_level_mean","expected_beta_mean","proposed_rate_mean","bandits_votes_mean","farmers_votes_mean", "reached_hierarchy", "time_to_hierarchy")
    rdict = rdict[!(vars %in% ext_vars)]
  } else if(type == "extended_var"){
    vars = as_vector(rdict)
    ext_vars = c("reached_hierarchy_mean", "time_to_hierarchy_mean")
    rdict = rdict[!(vars %in% ext_vars)]
  }
  
  selectInput(dd_name, param_name, choices = rdict, selected = selc, multiple = FALSE)
}