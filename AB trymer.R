
  pathAB<-list.files(path = "C:\\Users\\mines\\AppData\\Roaming\\Apple Computer\\MobileSync\\Backup", '31bb7ba8914766d4ba40d6dfb6113c8b614be442',full.names=TRUE, recursive = TRUE)
  pathSMS<-list.files(path = "C:\\Users\\mines\\AppData\\Roaming\\Apple Computer\\MobileSync\\Backup", '3d0d7e5fb2ce288813306e4d4636395e047a3d28',full.names=TRUE, recursive = TRUE)
    
    
dbAB <- dbConnect(SQLite(), pathAB)
  AB <- dbGetQuery(
    dbAB, 
    "SELECT ABPerson.first,ABPerson.last, ABMultiValue.value from ABPerson,ABMultiValue where ABMultiValue.record_id=ABPerson.ROWID")
  dbDisconnect(dbAB)
  
  vec<- AB$value
  first<-AB$First
  last<-AB$Last
  displayName<-c()
  
  for (i in 1:length(vec)) {
    test<-gsub(' ','',vec[i])
    vec[i]<-test
    }
  AB<-cbind(AB, vec)

  for (j in 1:nrow(AB)) {
    if(is.na(last[j])== FALSE ){
      
    displayName[j]<-paste(first[j], last[j], sep = ' ')
    }
    else{displayName[j]<-first[j]}
  }
  ABc<-as.data.frame(cbind(displayName[!is.na(vec)],vec[!is.na(vec)]))
  colnames(ABc)<-c('name','who')
  
#####################################
  

    dbsms <- dbConnect(SQLite(), pathSMS)
    sms <- dbGetQuery(
      dbsms, 
      "SELECT date/1000000000+978307200 AS date, datetime(date/1000000000+978307200,'unixepoch') AS xdate ,text, is_sent AS sent, id AS who
        FROM message
        JOIN handle
        ON message.handle_id = handle.ROWID")
    dbDisconnect(dbsms)
  
#####################################
full<- merge(x = sms, y = ABc, by = "who", all.x = TRUE)

# IT WORKS !!!!!!!!

