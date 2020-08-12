## app.R ##
source("uiutils.R")
source("data.R")
source("graphs.R")

mycss <- "
.mycheckbox .shiny-input-container {
  display: inline-block;
  width: auto;
}
"

ui <- dashboardPage(
  dashboardHeader(title = "Stationary Bandits"),
  dashboardSidebar(width=250,
                   sidebarMenu(
                     menuItem("Understand the Model", tabName = "info", icon = icon("info-sign", lib="glyphicon")),
                     menuItem("Baseline", tabName = "baseline", icon = icon("tent", lib="glyphicon"),
                              menuSubItem("Exploratory Analysis", tabName = "baseline_expan"),
                              menuSubItem("Regressions", tabName = "baseline_regdm")),
                     menuItem("Extended",tabName = "extended", icon = icon("university"),
                              menuSubItem("Exploratory Analysis", tabName = "extended_expan"),
                              menuSubItem("Regressions", tabName = "extended_regdm"))
  )),
  dashboardBody(
    
    tabItems(
      # includeMarkdown(knitr::knit('model.Rmd')
      
    
      tabItem(tabName = "baseline_expan", tabsetPanel(
      tabPanel("Error Bars", fluidRow(
        box(
          status = "info",
          title = "Parameters",
          div(id="bslParams",
              shinyjs::useShinyjs(),
              uiOutput("ui_bslEbProdAdv"),
              uiOutput("ui_bslEbForsInc"),
              uiOutput("ui_bslEbPropBnd"),
              uiOutput("ui_bslEbPercNof")),
              #actionButton("bslEbRandom", "Random Configuration", style = "display:block; color: white; background-color: rgb(60, 141, 188); border-radius: 6px;")),
          br(),    
          numericInput("bslEbMaxTicks","Max Ticks",25),
          hr(),
          div(style="font-size:18px", checkboxInput("bslEbVar", "Arrange by Variance", value = FALSE)),
          div(style="display:inline-block",
            numericInput("bslEbRank","Rank",1),
            uiOutput("ui_bslEbVars")
          ),
        ),
        box(status = "success", plotOutput("bslEbIncome", height = 270)),
        box(status = "danger", plotOutput("bslEbCounts", height = 270)),
        box(status = "warning", plotOutput("bslEbParams", height = 270))
      )),
      tabPanel("Box Plots", 
               fluidRow(
                 box(status="info", width = 12,
                     column(3,uiOutput("ui_bslBpX")),
                     column(3,uiOutput("ui_bslBpY")),
                     column(3,uiOutput("ui_bslBpZ")),
                     column(3,numericInput("bslBpMaxTicks","Max Ticks",25)),
                     htmlOutput("bslBpError")
                     )
               ),
               fluidRow(
                 box(status="success",plotOutput("bslBpPlot", height = 600), width = 12)
               )
      ),
      tabPanel("Random Runs", fluidRow())
    )),
    
    tabItem(tabName = "extended_expan", tabsetPanel(
      tabPanel("Error Bars", fluidRow(
        box(
          tags$style(mycss),
          status = "info",
          title = "Parameters",
          div(id="extParams",
              shinyjs::useShinyjs(),
              uiOutput("ui_extEbProAdv"),
              uiOutput("ui_extEbForsInc"),
              uiOutput("ui_extEbPropBnd"),
              uiOutput("ui_extEbPercNof")
              #actionButton("extEbRandom", "Random Configuration", style = "display:inline; color: white; background-color: rgb(60, 141, 188); border-radius: 6px;"),
              #span(class="mycheckbox",checkboxInput("extEbHierac", "Hierachy reached?", value = FALSE))
              ),
          br(),    
          numericInput("extEbMaxTicks","Max Ticks",100),
          hr(),
          div(style="font-size:18px", checkboxInput("extEbVar", "Arrange by Variance", value = FALSE)),
          div(style="display:inline-block",
              numericInput("extEbRank","Rank",1),
              uiOutput("ui_extEbVars")
          ),
        ),
        box(status = "success", plotOutput("extEbIncome", height = 300)),
        box(status = "success", plotOutput("extEbAsl", height = 300)),
        box(status = "warning", plotOutput("extEbBetas", height = 300)),
        box(status = "warning", plotOutput("extEbRates", height = 300)),
        box(status = "danger", plotOutput("extEbCounts", height = 300))
      )),
      tabPanel("Box Plots", 
               fluidRow(
                 box(status="info", width = 12,
                     fluidRow(
                       column(3,uiOutput("ui_extBpX")),
                       column(3,uiOutput("ui_extBpY")),
                       column(3,uiOutput("ui_extBpZ")),
                       column(3,numericInput("extBpMaxTicks","Max Ticks",100))
                     ),
                     fluidRow(
                       column(3, radioButtons("extLevel", "Association Level", selected = "Both",
                                              inline = TRUE, choices = c("Anarchy", "Hierarchy", "Both"))),
                       column(3, div(id="extRH",
                                     shinyjs::useShinyjs(),
                                     numericInput("extPercRH","Percentage of Runs in which Hierarchy was Reached",0.8)))
                     ),
                    
                     htmlOutput("extBpError")
                 )
               ),
               fluidRow(
                 box(status="success",plotOutput("extBpPlot", height = 600), width = 12)
               )
      ),
      tabPanel("Random Runs", fluidRow())
    ))
    
    # tags$style(mycss), class="mybackground", 
    ,tabItem(tabName = "info", tags$iframe(style="width: 100%; border: none; height:4000px", src = "model.html")  )
    ,tabItem(tabName = "extended_regdm", tags$iframe(style="width: 100%; border: none; height:2000px", src = "regressionsext.html"))
    )
  )
  
  
)

server <- function(input, output, session) {
  
  database <- read_data("baseline")
  pmap <- database$map
  avgs <- database$avgs
  vars <- database$vars
  
  database <- read_data("extended")
  pmap_ext <- database$map
  avgs_ext <- database$avgs
  vars_ext <- database$vars
  
  dicts <- read_dictionaries()
  pdict <- dicts$pdict
  edict <- dicts$edict
  rev_pdict <- dicts$rev_pdict
  rev_edict <- dicts$rev_edict
  
  database = NULL
  dicts = NULL

  output$ui_bslEbProdAdv <- renderUI({
    createSlider(pmap, pdict, "bslEbProdAdv","prod_advantage")
  })
  
  output$ui_bslEbForsInc <- renderUI({
    createSlider(pmap, pdict,"bslEbForsInc","foragers_income")
  })
  
  output$ui_bslEbPropBnd <- renderUI({
    createSlider(pmap, pdict, "bslEbPropBnd","prop_bandits")
  })
  
  output$ui_bslEbPercNof <- renderUI({
    createSlider(pmap, pdict, "bslEbPercNof","perc_non_farmers")
  })
  
  output$ui_bslBpX <- renderUI({
    createDropdown(rev_pdict, "bslBpX", "X", "prod_advantage")
  })
  
  output$ui_bslBpY <- renderUI({
    createDropdown(rev_edict, "bslBpY", "Y", "farmers_avg_income_mean")
  })
  
  output$ui_bslBpZ <- renderUI({
    createDropdown(rev_pdict, "bslBpZ", "Z", "foragers_income")
  })
  
  output$ui_bslEbVars <- renderUI({
    createDropdown(rev_edict, "bslEbOrder", "Variable", "pop_avg_income_mean")
  })
  
  baseline_eb <- reactive({
    
    ginc = NULL
    gctn = NULL
    gpar = NULL
    pars = NULL

    if(input$bslEbVar){
      
      ordered_vars = arrange_by(vars, input$bslEbOrder)
      id = as.integer(ordered_vars[input$bslEbRank,"id"])
      tbl = select_by_id(avgs, n_id = id, max_ticks = input$bslEbMaxTicks)
      pars = pmap[which(pmap$id == id),]
      
      shinyjs::disable("bslParams")
      
    } else {
      
      shinyjs::enable("bslParams")
        
      prod_adv = input$bslEbProdAdv
      forg_inc = input$bslEbForsInc
      prop_bnd = input$bslEbPropBnd
      perc_nof = input$bslEbPercNof
      
      tbl = select_by_params(avgs, pmap, input$bslEbMaxTicks, prod_adv, forg_inc, prop_bnd, perc_nof)
    }
    
    # tbl = pick_random(avgs, max_ticks = input$bslEbMaxTicks,n_samples = 1)
    # pars = pmap[which(pmap$id == as.integer(tbl[1,"id"])),]

    if(!is.null(pars)){
      
      updateSliderInput(session, "bslEbProdAdv", value = as.numeric(pars$prod_advantage))
      updateSliderInput(session, "bslEbForsInc", value = as.numeric(pars$foragers_income))
      updateSliderInput(session, "bslEbPercNof", value = as.numeric(pars$perc_non_farmers))
      updateSliderInput(session, "bslEbPropBnd", value = as.numeric(pars$prop_bandits))
    }
    
    if(nrow(tbl) != 0){
      tbl_inc = reshape_vars(tbl,c("id","tick"),c("pop_avg_income","farmers_avg_income","bandits_avg_income"))
      ginc = error_bars(tbl_inc,"tick","series","name","Incomes over Time",edict)
      
      tbl_cnt = reshape_vars(tbl,c("id","tick"),c("n_bandits","n_foragers"))
      gctn = error_bars(tbl_cnt,"tick","series","name","Agent Counts over Time",edict)
      
      tbl_par = reshape_vars(tbl,c("id","tick"),c("rate","beta"))
      gpar = error_bars(tbl_par,"tick","series","name","Appropriation Rate and Beta over Time",edict)
      
    } 
    
    return(list(incomes = ginc, counts = gctn, params = gpar))
  }) 
  
  baseline_bp <- reactive({
    
    errorMsg = ""
    boxPlot = NULL
    
    x = input$bslBpX
    y = input$bslBpY
    z = input$bslBpZ
    
    if(x == y || y == z || x == z){
      errorMsg = '<p style="color:red; float:left">Invalid variables: X, Y, and Z must hold different values.</p>'
      return(list(text = errorMsg, plot = boxPlot))
    }
    
    final <- pick_end_values(avgs,input$bslBpMaxTicks,"mean") %>% inner_join(pmap,by="id")
    boxPlot = box_plots(final,x,y,z)
    
    return(list(text = errorMsg, plot = boxPlot))
  })
  
  output$bslEbIncome <- renderPlot({baseline_eb()$incomes})
  output$bslEbCounts <- renderPlot({baseline_eb()$counts})
  output$bslEbParams <- renderPlot({baseline_eb()$params})
  output$bslBpError <- renderText({baseline_bp()$text})
  output$bslBpPlot <- renderPlot({baseline_bp()$plot})
  
  output$ui_extEbProAdv <- renderUI({
    createSlider(pmap_ext, pdict, "extEbProAdv","prod_advantage")
    #sliderInput("extEbProAdv", pdict$get("prod_advantage"), 0.1, 0.9, 0.5, step = 0.1, animate =
                  #animationOptions(interval = 2000, loop = FALSE))
  })
  
  output$ui_extEbForsInc <- renderUI({
    createSlider(pmap_ext, pdict,"extEbForsInc","foragers_income")
  })
  
  output$ui_extEbPropBnd <- renderUI({
    createSlider(pmap_ext, pdict, "extEbPropBnd","prop_bandits")
  })
  
  output$ui_extEbPercNof <- renderUI({
    createSlider(pmap_ext, pdict, "extEbPercNof","perc_non_farmers")
  })
  
  output$ui_extBpX <- renderUI({
    createDropdown(rev_pdict, "extBpX", "X", "prod_advantage","extended")
  })
  
  output$ui_extBpY <- renderUI({
    createDropdown(rev_edict, "extBpY", "Y", "farmers_avg_income_mean","extended")
  })
  
  output$ui_extBpZ <- renderUI({
    createDropdown(rev_pdict, "extBpZ", "Z", "foragers_income","extended")
  })
  
  output$ui_extEbVars <- renderUI({
    createDropdown(rev_edict, "extEbOrder", "Variable", "pop_avg_income_mean", "extended_var")
  })
  
  extended_eb <- reactive({
    
    ginc = NULL
    gctn = NULL
    gpar = NULL
    pars = NULL
    
    if(input$extEbVar){
      
      ordered_vars = arrange_by(vars_ext, input$extEbOrder)
      id = as.integer(ordered_vars[input$extEbRank,"id"])
      tbl = select_by_id(avgs_ext, n_id = id, max_ticks = input$extEbMaxTicks)
      pars = pmap_ext[which(pmap_ext$id == id),]
      
      shinyjs::disable("extParams")
    } else {
      
      shinyjs::enable("extParams")
      
      prod_adv = input$extEbProAdv
      forg_inc = input$extEbForsInc
      prop_bnd = input$extEbPropBnd
      perc_nof = input$extEbPercNof
      
      tbl = select_by_params(avgs_ext, pmap_ext, input$extEbMaxTicks, prod_adv, forg_inc, prop_bnd, perc_nof)
      
    }
      
    # if(input$extEbRandom){
    # 
    #   tbl = pick_random(avgs_ext, max_ticks = input$extEbMaxTicks,n_samples = 1)
    #   pars = pmap_ext[which(pmap_ext$id == as.integer(tbl[1,"id"])),]
    # }

    if(!is.null(pars)){
      
      updateSliderInput(session, "extEbProAdv", value = as.numeric(pars$prod_advantage))
      updateSliderInput(session, "extEbForsInc", value = as.numeric(pars$foragers_income))
      updateSliderInput(session, "extEbPercNof", value = as.numeric(pars$perc_non_farmers))
      updateSliderInput(session, "extEbPropBnd", value = as.numeric(pars$prop_bandits))
    }
    
    if(nrow(tbl) != 0){
      xmin = get_al_xmin(tbl)
      
      if(!is.null(xmin) && xmin > input$extEbMaxTicks){
        xmin = NULL
      }

      gasl <- ts_plot(tbl, "tick","association_level_mean", "Association Level", "Mean over Runs")
      
      tbl_inc = reshape_vars(tbl,c("id","tick"),c("farmers_avg_income","bandits_avg_income"))
      ginc = error_bars(tbl_inc,"tick","series","name","Incomes over Time", edict, shade = xmin)
      
      tbl_cnt = reshape_vars(tbl,c("id","tick"),c("n_bandits","n_foragers"))
      gctn = error_bars(tbl_cnt,"tick","series","name","Agent Counts over Time",edict, shade = xmin)
      
      tbl_beta = reshape_vars(tbl,c("id","tick"),"beta")
      gbeta = error_bars(tbl_beta,"tick","series","name","Beta",edict, shade = xmin)
      
      tbl_rate = reshape_vars(tbl,c("id","tick"),c("rate","proposed_rate"))
      grate = error_bars(tbl_rate,"tick","series","name","Appropriation Rate vs Proposed Tax Rate",edict, shade = xmin)
    } 
    
    return(list(incomes = ginc, counts = gctn, betas = gbeta, rates = grate, asl = gasl))
  }) 
  
  extended_bp <- reactive({
    
    errorMsg = ""
    boxPlot = NULL
    
    x = input$extBpX
    y = input$extBpY
    z = input$extBpZ
    
    if(x == y || y == z || x == z){
      errorMsg = '<p style="color:red; float:left">Invalid variables: X, Y, and Z must hold different values.</p>'
      return(list(text = errorMsg, plot = boxPlot))
    }
    
    level = input$extLevel 
    
    if(y == "time_to_hierarchy_mean" || level == "Hierarchy"){
      shinyjs::enable("extPercRH")
    } else {
      shinyjs::disable("extPercRH")
    }
    
    if(level == "Both"){
      sub_avgs = avgs_ext
    } else if(level == "Hierarchy"){
      sub_avgs = subset_per_level(avgs_ext, "Hierarchy", input$extPercRH)
    } else {
      sub_avgs = subset_per_level(avgs_ext, "Anarchy")
    }
    
    final <- pick_end_values(sub_avgs,input$extBpMaxTicks,"mean") %>% inner_join(pmap_ext,by="id")
    
    if(y == "time_to_hierarchy_mean"){
      final <- join_with_tth(final)
    } 
    
    boxPlot = box_plots(final,x,y,z)
    
    return(list(text = errorMsg, plot = boxPlot))
  })
  
  output$extEbIncome <- renderPlot({extended_eb()$incomes})
  output$extEbAsl <- renderPlot({extended_eb()$asl})
  output$extEbCounts <- renderPlot({extended_eb()$counts})
  output$extEbBetas <- renderPlot({extended_eb()$betas})
  output$extEbRates <- renderPlot({extended_eb()$rates})
  
  output$extBpError <- renderText({extended_bp()$text})
  output$extBpPlot <- renderPlot({extended_bp()$plot})
}

shinyApp(ui, server)

