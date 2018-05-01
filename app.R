rm(list = ls())

library(shiny)
library(DBI)
library(RMySQL)
library(shinydashboard)
library(DT)
library(rsconnect)
#For file read
library(rio)  #convert xls to csv
#install_formats() # formats for rio
library(readxl) #To read excel files
library(koboloadeR)
#For plotting maps
library(ggmap)
library(ggplot2)
library(ggrepel)
library(reshape2)
library(tidyverse)
#For Doc gen
library(rmarkdown)
library(knitr)
library(tinytex)
#library(tufte)
#For analysis
library(lme4)
library(formatR)
# library(stats)
# library(arm)
library(Matrix)
library(stargazer)
library(car)

#library(mosaic)
#library(gdata) #read.xls into data frame
#library(data.table)  #fread

source("./dataRetrieval.R")

#For stack trace error, place it right after the error code
#traceback()

#For Kobo
pass = "preethi1433:91428836pP"

#For MySQL
dbArguments <- list(
  drv = RMySQL::MySQL(),
  user='preethi',
  password='root',
  dbname='project',
  host='127.0.0.1')

#For getting bibtex citation
#citation()
#citation(package="shiny")

ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Mistletoes"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Get Data from SMAP XLS",tabName = "datapull"),
      menuItem("Get Data from KOBO",tabName = "datapullkobo"),
      menuItem("Write raw to DB", tabName = "rawupload"),
      menuItem("Write raw kobo to DB", tabName = "rawuploadkobo"),
      menuItem("Structure the Data to DB",tabName = "structure"),
      menuItem("Write DB to CSVs",tabName = "csvwrite"),
      menuItem("Plot",tabName = "plot"),
      menuItem("Create a cool markdown",tabName = "coolreport")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "datapull", 
              fluidPage(
                fluidRow(
                  column(2, 
                         actionButton(inputId = "SMAPButton", "Import SMAP CSV",width = '200px',
                                      style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
                  column(9, 
                         offset = 1, verbatimTextOutput("VTOdwnldstatus", placeholder = FALSE))),
                fluidRow(
                  column(12,
                         verbatimTextOutput("VTObuffertext",placeholder = FALSE)),
                  column(12, 
                         DT::dataTableOutput("SMAPdata", height = "auto"))))),
      tabItem(tabName = "datapullkobo", 
              fluidPage(
                fluidRow(
                  column(2, 
                         actionButton(inputId = "KOBOButton", "Import KOBO",width = '200px',
                                      style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
                  column(9, 
                         offset = 1, verbatimTextOutput("VTOdwnldstatuskobo", placeholder = FALSE))),
                fluidRow(
                  column(12,
                         verbatimTextOutput("VTObuffertextkobo",placeholder = FALSE)),
                  column(12, 
                         DT::dataTableOutput("KOBOdata", height = "auto"))))),
      tabItem(tabName = "rawupload",
              verbatimTextOutput("VTOuploadstatus", placeholder = FALSE),
              DT::dataTableOutput("mysqldata", height = "auto")),
      tabItem(tabName = "rawuploadkobo",
              verbatimTextOutput("VTOuploadstatuskobo", placeholder = FALSE),
              DT::dataTableOutput("mysqldatakobo", height = "auto")),
      tabItem(tabName = "structure",
              fluidPage(
                fluidRow(
                  column(12, uiOutput("tableSelector")),
                  column(12, uiOutput("columnSelector")),
                  column(5, 
                         actionButton(inputId = "makesubtable", 
                                      "Make Filtered Table",
                                      width = '200px'),
                         textInput(inputId = "tblinput",
                                   label = "Enter the table name for MySQL : ",
                                   placeholder = "Enter a lowercase string without space"),
                         actionButton(inputId = "upload",
                                      "Upload to DB",
                                      width = '200px'))),
                fluidRow(
                  column(12,
                         DT::dataTableOutput("selecteddatarenderer", height = "auto"))))),
      tabItem(tabName = "csvwrite",
              fluidPage(
                fluidRow(
                  column(12, uiOutput("tableSelectorcsv")),
                  downloadButton(outputId = "downloadData", 
                                 "Download as CSV")))),
      tabItem(tabName = "plot",
              verbatimTextOutput("VTOplotstatus", placeholder = FALSE),
              plotOutput("graphs")),
      tabItem(tabName = "coolreport",
              #verbatimTextOutput("VTOreportstatus", placeholder = FALSE),
              #downloadButton("pdfreport", "Download Report as PDF"),
              uiOutput("reportPreview")))
  )
)

server <- function(input, output, session) {
  #----------------------------------Reactive Variables----------------------------------#
  download <- reactiveValues(dwnldstatus = "No data available")
  downloadkobo <- reactiveValues(dwnldstatuskobo = "No data available from KOBO")
  upload <- reactiveValues(uploadstatus = "Raw data not uploaded yet")
  uploadkobo <- reactiveValues(uploadstatuskobo = "Raw KOBO data not uploaded yet")
  buffer <- reactiveValues(bufferstatus = "The data imported from CSV displayed below")
  bufferkobo <- reactiveValues(bufferstatuskobo = "The data imported from KOBO displayed below")
  plots <- reactiveValues(plotstatus = "No graphs available")
  #reports <- reactiveValues(reportstatus = "No reports generated. If generated, will be displayed below")
  
  output$VTOdwnldstatus <- renderText({download$dwnldstatus})
  output$VTOdwnldstatuskobo <- renderText({downloadkobo$dwnldstatuskobo})
  output$VTObuffertext <- renderText({buffer$bufferstatus})
  output$VTObuffertextkobo <- renderText({bufferkobo$bufferstatuskobo})
  output$VTOuploadstatus <- renderText({upload$uploadstatus})
  output$VTOuploadstatuskobo <- renderText({uploadkobo$uploadstatuskobo})
  output$VTOplotstatus <- renderText({plots$plotstatus})
  #output$VTOreportstatus <- renderText({reports$reportstatus})
  #----------------------------------Session Variables----------------------------------#
  tibble_all_data <- data.frame()
  mysubtable <- data.frame()
  
  kobo_all_data <- data.frame()
  
  #-------------DB Tables for Markdown---------------------#
  hosts_table<-data.frame()
  parasite_table<-data.frame()
  rawdata_table<-data.frame()
  rawdata_backup_table<-data.frame()
  species_table<-data.frame()
  site_table<-data.frame()
  sub_site_table<-data.frame()
  #----------------------------------Read data from CSV to R----------------------------------#
  output$SMAPdata <- DT::renderDataTable({
    req(input$SMAPButton)
    download$dwnldstatus = "No data available"
    all_data <- data.frame()
    
    #tibble_all_data <- read_xlsx("pivot.xlsx",sheet = "aranya", range = "A1:P1048", 
    #                              col_names = TRUE, 
    #                              col_types = c("skip", "text", "text", "text", "numeric", "numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","text","text","text"), 
    #                              trim_ws = TRUE)
    #tibble_all_data <- read.csv("parasite.csv", header = TRUE, sep = ",", dec = ".", strip.white = TRUE, 
    #                            blank.lines.skip = TRUE, na.strings = c("",".","NA"))
    
    #Convert XLS to CSV using rio package
    #convert(in_file = "lifexls.xls", out_file = "lifenew.csv", out_opts = list(format = "csv"))
    #DONE
    
    #Trial read as excel
    #all_data <- read_excel("life.xls", sheet = "mist", range = "N681:AF1727", col_names = TRUE, col_types = NULL,
    #                       na = c("NA"), trim_ws = TRUE, guess_max = 15)
    
    all_data <- fread(input = "lifenew.csv", sep = ",", header = TRUE,
                      na.strings = c("",".","NA"), check.names = TRUE,
                      encoding = "UTF-8", fill = TRUE, blank.lines.skip = TRUE,
                      data.table = FALSE, showProgress = TRUE,
                      drop = c(1,2,3,4,5,6,7,8,9,10,11,12,13,33,34,35))
    
    #read csv without phenology
    # all_data <- fread(input = "parasite.csv", sep = ",", header = TRUE, 
    #                   na.strings = c("",".","NA"), check.names = TRUE, 
    #                   encoding = "UTF-8", fill = TRUE, blank.lines.skip = TRUE, 
    #                   data.table = FALSE, showProgress = TRUE,
    #                   drop = c(1,2,3,4,5,6,7,8,9,10,11,12,13,33,34,35))
    
    #unlink("parasite.csv")
    
    #Use gdata to read as xls
    #all_data <- read.xls(xls = "lifexls.xls", sheet = "mist", method = "csv", na.strings = c("",".","NA"), 
    #                     blank.lines.skip = TRUE, header = TRUE)
    showNotification("CSV Data")
    #Manually change all values missing to NA
    # for(i in 1:nrow(mistletoe_selected.data)){
    #   for(j in 1:ncol(mistletoe_selected.data)){
    #     if(mistletoe_selected.data[i, j] == "n/a"){
    #       mistletoe.data[i,j] <- ""
    #     }
    #   }
    # }
    #Convert missing values to NA
    #tibble_all_data[tibble_all_data == "n/a"] = NA
    #tibble_all_data[tibble_all_data == ""] = NA
    
    all_data[is.na(all_data)] <- 0
    
    #tibble_all_data[is.na(tibble_all_data)] = NA
    
    download$dwnldstatus = "Data obtained from XLS to tibble"
    #    mistletoe_selected.data <<- mistletoe.data[,c(7, 14, 15, 16)]
    
    tibble_all_data <<- all_data
    tibble_all_data
  },options = list(autoWidth = TRUE, scrollX = TRUE, orderClasses = TRUE))
  #----------------------------------Upload Raw Data to DB----------------------------------#
  output$mysqldata <- DT::renderDataTable({
    req(input$SMAPButton)
    upload$uploadstatus = "Raw data not uploaded yet"
    if(download$dwnldstatus == "Data obtained from XLS to tibble"){
      conn <- do.call(DBI::dbConnect, dbArguments)
      on.exit({
        print("On exit disconnect 1")
        DBI::dbDisconnect(conn)})
      tryCatch({
        if(dbExistsTable(conn, "rawdata") == FALSE){
          print("Table doesn't exist")
          typesfield <- list(site = "varchar(30)", plot = "varchar(30)", quadrat = "varchar(30)", host = "varchar(50)", 
                             phenologyhost1 = "integer",phenologyhost2 = "integer", phenologyhost3 = "integer",
                             light = "float(5,2)", 
                             gbh1 = "float(5,2)", gbh2 = "float(5,2)", gbh3 = "float(5,2)", gbh4 = "float(5,2)", gbh5 = "float(5,2)", 
                             infest = "integer", biomass = "integer",
                             phenologypar1 = "integer", phenologypar2 = "integer", phenologypar3 = "integer", clump = "integer")
          dbWriteTable(conn, name = "rawdata", 
                       value = tibble_all_data, 
                       row.names = FALSE, 
                       append = FALSE, 
                       field.types = typesfield)
          print(tibble_all_data)
        }
      },warning = function(w){
        print(w)
      },
      error = function(e) {
        print(e)
      },
      finally = {
        print("Exiting finally")
        # if(dbIsValid(conn))
        #   dbDisconnect(conn)
      })
      showNotification("Written raw data in the DB", duration = NULL, closeButton = TRUE, type = "message")
      upload$uploadstatus = "Raw data uploaded"
      conn <- do.call(DBI::dbConnect, dbArguments)
      on.exit({
        print("On exit disconnect 2")
        DBI::dbDisconnect(conn)})
      
      if(dbExistsTable(conn, "rawdata") == TRUE){
        datafrommysql <- dbGetQuery(conn, "SELECT * FROM rawdata")
        upload$uploadstatus = "Showing below the uploaded rawdata"
      }
      return(datafrommysql)
    }
  },options = list(autoWidth = TRUE, scrollX = TRUE, orderClasses = TRUE))
  
  #---------------------------------Read KOBO Data-----------------------------------#
  output$KOBOdata <- DT::renderDataTable({
    req(input$KOBOButton)
    downloadkobo$dwnldstatuskobo = "No data available from KOBO"
    data.sets = kobo_datasets(user = pass, api = "kobo")
    data.sets
    my.id = as.double(which(data.sets$description == 'Reconnaisance'))
    my.id
    mistletoe.data = data.frame(kobo_data_downloader(data.sets$id[my.id], 
                                                     user = pass, 
                                                     api = "kobo", 
                                                     check = TRUE),
                                stringsAsFactors = FALSE)
    downloadkobo$dwnldstatuskobo = "Downloaded your data"
    kobon = kobo_submission_count(formid = data.sets$id[my.id], user = pass, api = "kobo")
    kobon
    #kobo_time_parser(TIME, timezone = "Asia/Rangoon")
    kobo_all_data<<-mistletoe.data
    kobo_all_data
  },options = list(autoWidth = TRUE, scrollX = TRUE, orderClasses = TRUE))
  
  #----------------------------------Upload Raw KOBO Data to DB----------------------------------#
  output$mysqldatakobo <- DT::renderDataTable({
    req(input$KOBOButton)
    uploadkobo$uploadstatuskobo = "Raw KOBO data not uploaded yet"
    if(downloadkobo$dwnldstatuskobo == "Downloaded your data"){
      conn <- do.call(DBI::dbConnect, dbArguments)
      on.exit({
        print("On exit disconnect")
        DBI::dbDisconnect(conn)})
      tryCatch({
        if(dbExistsTable(conn, "rawdatakobo") == FALSE){
          print("Table doesn't exist")
          dbWriteTable(conn, 
                       value = kobo_all_data,
                       name = "rawdatakobo",
                       append = FALSE,
                       row.names = FALSE)
        }
      },warning = function(w){
        print(w)
      },
      error = function(e) {
        print(e)
      },
      finally = {
        print("Exiting")
        if(dbIsValid(conn))
          dbDisconnect(conn)
      })
      showNotification("Written KOBO in the DB", duration = NULL, closeButton = TRUE, type = "message")
      uploadkobo$uploadstatuskobo = "KOBO Data uploaded"
      
      conn <- do.call(DBI::dbConnect, dbArguments)
      on.exit(DBI::dbDisconnect(conn))
      
      if(dbExistsTable(conn, "rawdatakobo") == TRUE){
        datafrommysqlkobo <- dbGetQuery(conn, "SELECT * FROM rawdatakobo")
        uploadkobo$uploadstatuskobo = "Showing below the uploaded KOBO data"
      }
      return(datafrommysqlkobo)
    }
  },options = list(autoWidth = TRUE, scrollX = TRUE, orderClasses = TRUE))
  
  #-----------Display radiobuttons with table name of the DB---------------------#
  output$tableSelector <- renderUI({
    #Writing a custom function to get list of table names
    tablesT <- list()
    tablesT <- getTableNames(dbArguments)
    tablesT
    fluidPage(
      fluidRow(column(6, radioButtons("dbTablesDB",
                                      "Choose the required table : ",
                                      choices = tablesT))
      )
    )
  })
  #---------------------Get list of column names---------------------------------------------------#
  output$columnSelector <- renderUI({
    #req necessary for avoiding Db errors unable to find an inherited method for function 
    #‘dbListFields’ for signature ‘"MySQLConnection", "NULL"
    req(input$dbTablesDB)
    tableN <- input$dbTablesDB
    print(tableN)
    columnT <- getColumnNames(dbArguments, tableN)
    print(columnT)
    fluidPage(
      fluidRow(column(6, selectInput("columnNames",
                                     "Choose the required columns :",
                                     choices = columnT,
                                     multiple = TRUE)))
    )
  })
  #-----------Construct a query string from the chosen table and columns to get the details from DB
  observeEvent(input$makesubtable, {
    req(input$columnNames)
    userSelection <- input$columnNames
    
    print(userSelection)
    queryStr <- "SELECT "
    queryStr <- paste(queryStr, "`", userSelection[1], "`", sep = "")
    
    for(column.name in userSelection[2:length(userSelection)]){
      queryStr <- paste(queryStr, ",","`", column.name, sep = "")
      queryStr <- paste(queryStr, "`", sep = "")
    }
    queryStr <- paste(queryStr, "FROM", input$dbTablesDB)
    showNotification(queryStr, duration = NULL, closeButton = TRUE, type = "message")
    mysubtable <<- getSelectedColumns(dbArguments, queryStr)
    return(mysubtable)
  })
  #-------------Render the data downloaded from the marshalled data-----------------#
  output$selecteddatarenderer <- renderDataTable({
    req(input$upload)
    tableToCreate <- input$tblinput
    
    conn <- do.call(DBI::dbConnect, dbArguments)
    on.exit({
      print("On exit disconnect")
      DBI::dbDisconnect(conn)})
    tryCatch({
      if((dbExistsTable(conn, tableToCreate) == FALSE)&&
         (dbExistsTable(conn, "rawdata")==TRUE)){
        print("Table doesnt exist")
        dbWriteTable(conn, 
                     value = mysubtable,
                     name = tableToCreate,
                     append = FALSE,
                     row.names = FALSE)
        print("Table created")
      }
    },warning = function(w){
      print(w)
    },
    error = function(e) {
      print(e)
    },
    finally = {
      print("Exiting")
    })
    showNotification("Written in the DB", duration = NULL, closeButton = TRUE, type = "message")
    conn <- do.call(DBI::dbConnect, dbArguments)
    on.exit(DBI::dbDisconnect(conn))
    
    quer <- paste("SELECT * FROM ", tableToCreate)
    print("Table what where who")
    print(paste(quer))
    mysubtemptable <- dbGetQuery(conn, quer)
    print(mysubtemptable)
    mysubtemptable
  },options = list(scrollX = TRUE, orderClasses = TRUE, verbose=TRUE))
  #-----------------Display radiobuttons with table name of the DB for downloading as CSV---------------------#
  output$tableSelectorcsv <- renderUI({
    #Writing a custom function to get list of table names
    tablesT2 <- list()
    tablesT2 <- getTableNames(dbArguments)
    print(tablesT2)
    fluidPage(
      fluidRow(column(6, radioButtons("dbTablesDB2",
                                      "Choose the required table : ",
                                      choices = tablesT2))
      )
    )
  })
  #-------------Download as CSV the marshalled data-----------------#
  output$downloadData <- downloadHandler(
    filename = function() {
      #paste("Data-", Sys.Date(), ".csv", sep = "")
      return(sprintf("%s.csv", format(Sys.time(), "DATA_%Y_%m_%d_%H_%M_%S")))
    },
    content = function(file) {
      #req(input$dbTablesDB2)
      write.csv(input$dbTablesDB2, file, row.names = FALSE,quote=TRUE)
    }
  )
  #----------------Graphs to plot----------------#
  output$graphs <- renderPlot({
    plots$plotstatus = "No graphs available"
    gps_pu<-read.csv("gps_pu.csv")
    perimeters_pu<-read.csv("perimeter.csv")
    perimeters_aranya<-read.csv("perimeter_aranya.csv")
    #------------------------------PU--------------------------------------#
    p<-ggplot(gps_pu, aes(lat, lon)) + 
      geom_point()
    p+geom_point(aes(x=lat, y=lon), data=gps_pu, shape=20, size=5, alpha=1, 
                 color="black")+
      geom_point(aes(x=lat, y=lon), data=perimeters_pu, shape=20, size=2, alpha=1, color="black")+
      geom_polygon( data = perimeters_pu, aes( alpha = 0.01))+
      geom_label_repel(data=gps_pu,aes(label=plot), alpha=0.7,fontface = 'bold',
                       color = 'black',box.padding = unit(1.25, "lines"),
                       segment.color = 'blue',point.padding = 1.6)
    calc_zoom(lon, lat, gps_pu, adjust = as.integer(0), f = 0.05)
    map <- get_map(location = c(lon = median(gps_pu$lon),
                                lat = median(gps_pu$lat)),
                   zoom=17,
                   maptype="toner",
                   color="color",
                   source="stamen")
    mymap = ggmap(map, darken = c(.2,"white"))
    mymap+geom_point(aes(x=lat, y=lon), data=gps_pu, shape=20, size=5, alpha=1, 
                     color="black")+
      geom_point(aes(x=lat, y=lon), data=perimeters_pu, shape=20, size=2, alpha=1, color="black")+
      geom_polygon( data = perimeters_pu, aes( alpha = 0.01))+
      geom_label_repel(data=gps_pu,aes(label=plot), alpha=0.7,fontface = 'bold',
                       color = 'black',box.padding = unit(1.25, "lines"),
                       segment.color = 'blue',point.padding = 1.6)
    #------------------------------ARANYA-------------------------------------#
    p1<-ggplot(perimeters_aranya, aes(lat,lon)) + 
      geom_point()+
      scale_y_continuous(limits=c(79.74,79.86))+
      scale_x_continuous(limits=c(11.95,12.026))
    p1+geom_point(aes(x=lat, y=lon,colour=plot,group=plot), 
                  data=perimeters_aranya, 
                  shape=1, size=0.5, alpha=1,color="black",show.legend = TRUE)
    
    p1+geom_point(data=perimeters_aranya,
                  aes(x=lat,y=lon,size=plot),
                  shape=1, size=1, alpha=1,color="black",show.legend = TRUE)
    #geom_polygon( data = perimeters_aranya, aes( alpha = 0.01))
    map1 <- get_map(location = c(lon = median(perimeters_aranya$lon),
                                 lat = median(perimeters_aranya$lat)),
                    zoom=13,
                    maptype="toner",
                    color="color",
                    source="stamen")
    mymap1 = ggmap(map1, darken = c(.05,"white"))
    #calc_zoom(lon, lat, perimeters_aranya, adjust = as.integer(0), f = 0.05)
    
    #meltdata <- melt(perimeters_aranya,id.vars = "lat")
    #mymap1+geom_point(data=meltdata,
    mymap1+geom_point(data=perimeters_aranya,
                      aes(x=lat,y=lon,size=plot,colour=plot),
                      shape=1, size=1, alpha=1,color="black",show.legend = TRUE)+
      geom_text(data=perimeters_aranya,
                aes(x=lat,y=lon,size=plot,label=plot))+
      labs(x = "Longitude", y = "Latitude", title = "Location of Aranya based on GPS data",
           colour = "plot")+
      geom_label_repel(data=perimeters_aranya,aes(label=plot), alpha=0.5,
                       colour = 'black',box.padding = unit(1.25, "lines"),
                       segment.colour = 'blue',point.padding = 1.6,
                       show.legend = TRUE)
    #+geom_smooth(method="lm")
    #geom_polygon(data = perimeters_aranya,aes(alpha = 0.01))+
    #stat_smooth(method = "lm")+
    #scale_color_brewer(palette = "Set1")+
    #+geom_polygon(data = perimeters_aranya, aes( alpha = 0.01))
    #+geom_label_repel(data=perimeters_aranya,aes(label=plot), alpha=0.7,fontface = 'bold',
    #                  color = 'black',box.padding = unit(1.25, "lines"),
    #                  segment.color = 'blue',point.padding = 1.6)
    print(mymap)
    print(mymap2)
    
    png("test.png")
    print(mymap1)
    dev.off()
    #ggmap(mymap)
    plots$plotstatus = "Plotted Graphs"
  })
  #----------------To generate report using Markdown---------------#
  output$reportPreview <- renderUI({
    hosts_table<-read.csv("sql/hosts.csv", header = TRUE, sep = ",", dec = ".",skipNul = TRUE)
    parasite_table<-read.csv("sql/parasite.csv", header = TRUE, sep = ",", dec = ".")
    rawdata_table<-read.csv("sql/rawdata.csv", header = TRUE, sep = ",", dec = ".")
    rawdata_backup_table<-read.csv("sql/rawdata_backup.csv", header = TRUE, sep = ",", dec = ".")
    species_table<-read.csv("sql/species.csv", header = TRUE, sep = ",", dec = ".")
    site_table<-read.csv("sql/site.csv", header = TRUE, sep = ",", dec = ".")
    sub_site_table<-read.csv("sql/sub_site.csv", header = TRUE, sep = ",", dec = ".")
    #reports$reportstatus="No reports generated. If generated, will be displayed below"
    
    
    iFrame <- withProgress(
      message = "Generating document preview...",{
        
        dirS <- tempdir()
        mapfilename<-file.path(dirS, "mapkobo.png")
        file.copy("mapkobo.png", mapfilename, overwrite = TRUE)
        
        mapfilename2<-file.path(dirS, "envis_frlht_india_dist.jpg")
        file.copy("envis_frlht_india_dist.jpg", mapfilename2, overwrite = TRUE)
        #Parameters for RMarkdown Rmd
        #table1 is defined in the Rmd file
        param <- list(table_host=hosts_table, 
                      table_parasite=parasite_table,
                      table_raw=rawdata_table,
                      table_rawbackup=rawdata_backup_table,
                      table_species=species_table,
                      table_site=site_table,
                      table_subsite=sub_site_table,
                      barColor="red",
                      map=mapfilename,
                      map2=mapfilename2)
        tempReport <- file.path(dirS, "landdmarkdown.Rmd")
        file.copy("./landdmarkdown.Rmd", tempReport, overwrite = TRUE)
        fileBaseName = sprintf("%s.pdf",
                               format(Sys.time(),
                                      "Markdown_Report_%Y_%m_%d_%H_%M_%S"))
        outputFile = file.path(dirS, fileBaseName)
        #envir the variables in this env visible to the render function
        rmarkdown::render(tempReport,
                          output_file = outputFile,
                          params = param,
                          envir = new.env(parent = globalenv()))
        #Ask Karpa there is problem in nuls with readlines below
        # tags$iframe(
        #   srcdoc = paste(readLines(outputFile), collapse = '\n'),
        #   width = "50%",
        #   height = "600px",
        #   seamless = NA
        # )
      })
    #reports$reportstatus="Report will be found in /tmp/R directory"
    iFrame
  })
}
shinyApp(ui = ui, server = server)