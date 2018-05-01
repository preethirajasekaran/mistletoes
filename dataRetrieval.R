getTableNames <- function(credentials){
  conn <- do.call(DBI::dbConnect, credentials)
  on.exit({
    print("On exit disconnect")
    DBI::dbDisconnect(conn)})
  
  withProgress(message = "RETRIEVING TABLE NAME FROM SERVER...",
               detail = "Wait awhile...", 
               value = 0, {
                 tryCatch({
                   listT <- dbListTables(conn)
                 },warning = function(w){
                   print(w)
                 },
                 error = function(e) {
                   print(e)
                 },
                 finally = {
                   print("Exiting")
                   # if(dbIsValid(conn))
                   #   dbDisconnect(conn)
                 })
                 for (i in 1:15) {
                   incProgress(1/15)
                   Sys.sleep(0.01)
                 }
               })
  #print(listT)
  listT
}

#-----------------------------------------------------------------------------#
getColumnNames <- function(credentials, tableToo){
  conn <- do.call(DBI::dbConnect, credentials)
  on.exit({
    print("On exit disconnect")
    DBI::dbDisconnect(conn)})
  withProgress(message = "RETRIEVING COLUMN NAME FROM SERVER...",
               detail = "Wait awhile...", 
               value = 0, {
                 tryCatch({
                   #A character vector
                   listC <- list()
                   print("In function")
                   print(tableToo)
                   listC <- DBI::dbListFields(conn, tableToo)
                 },warning = function(w){
                   print(w)
                 },
                 error = function(e) {
                   print(e)
                 },
                 finally = {
                   print("Exiting")
                 })
                 for (i in 1:15) {
                   incProgress(1/15)
                   Sys.sleep(0.01)
                 }
               })
  #print(listT)
  return(listC)
}

#-----------------------------------------------------------------------------#
getSelectedColumns <- function(credentials, queryString){
  conn <- do.call(DBI::dbConnect, credentials)
  on.exit({
    print("On exit disconnect")
    DBI::dbDisconnect(conn)})
  withProgress(message = "RETRIEVING SELECTED COLUMNS FROM SERVER...",
               detail = "Wait awhile...", 
               value = 0, {
                 tryCatch({
                   #A character vector
                   dataframe <- data.frame()
                   print("In function")
                   print(queryString)
                   dataframe <- dbGetQuery(conn, queryString)
                 },warning = function(w){
                   print(w)
                 },
                 error = function(e) {
                   print(e)
                 },
                 finally = {
                   print("Exiting")
                 })
                 for (i in 1:15) {
                   incProgress(1/15)
                   Sys.sleep(0.01)
                 }        
               })
  #print(listT)
  return(dataframe)
}