error_bars <- function(tbl, x_var, y_var, group_var, title, pdict, shade = NULL, subtitle = "", y_lab = "", caption = ""){
  
  theme_set(theme_bw())
  
  nms = names(tbl)[grep(y_var,names(tbl))]
  mean_nm = as.name(nms[grep("mean", nms)])
  sd_nm = as.name(nms[grep("sd", nms)])
  means = as_vector(tbl[,mean_nm])
  sds = as_vector(tbl[,sd_nm])
  
  groups = as_vector(tbl[,group_var])
  group_vals = unique(groups)
  maxTick <- as.integer(max(tbl$tick)[1])
  
  lab = NULL
  for(elem in group_vals){
    lab = c(lab, pdict$get(elem))
  }
  
  #tbl <- tbl %>% mutate(ymin = !!mean_nm - !!sd_nm, ymax = !!mean_nm + !!sd_nm)
  
  tbl <- tibble(x = as_vector(tbl[,x_var]), 
                y = means, 
                id = groups, 
                ymax = means + sds, 
                ymin = means - sds) 
  
  g <- ggplot(tbl, aes(x=x, y=y, group=id, color=id)) 
  
  if(!is.null(shade)){
    g <- g + annotate("rect", xmin = shade, xmax = maxTick, ymin = 0, ymax = Inf, fill = "lightblue", alpha = 0.2) 
  }
  
  g <- g + geom_line() +
            geom_point()+
            geom_errorbar(aes(ymin=ymin, ymax=ymax)) + 
            labs(title=title, 
                 subtitle=subtitle, 
                 caption=caption, 
                 y=y_lab,
                 x="Tick") + 
            theme(panel.grid.minor = element_blank(), 
                  axis.text.x = element_text(angle = 45, vjust=0.5), 
                  legend.position="bottom") 
  
    if(!is.null(lab)){
      g <- g + scale_color_discrete(name = "Variables", breaks = group_vals, labels = lab) 
    }

    return(g)
}

ts_plot <- function(tbl, x, y, title, subtitle = "", y_lab = "", caption = ""){
  
  tbl <- tibble(x = as_vector(tbl[,x]), 
                y = as_vector(tbl[,y]))
  
  theme_set(theme_bw())
  ggplot(data = tbl, aes(x=x, y=y)) + 
    geom_line() +
    labs(title=title, 
         subtitle=subtitle, 
         caption=caption, 
         y=y_lab,
         x="Tick") + 
    theme(panel.grid.minor = element_blank(), 
          axis.text.x = element_text(angle = 45, vjust=0.5), 
          legend.position="bottom") 
  
}

box_plots <- function(tbl, x, y, z){
  
  tbl <- tibble(x = as_vector(tbl[,x]), 
                y = as_vector(tbl[,y]), 
                z = as_vector(tbl[,z]))
  
  theme_set(theme_bw())
  ggplot(data = tbl, aes(x=x, y=y)) + 
        geom_boxplot(aes(group=x)) +
        facet_wrap( ~ z, scales="free")
}