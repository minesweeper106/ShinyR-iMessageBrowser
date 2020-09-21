parser <- function(data,id=NULL, dateStart=NULL, dateEnd=NULL) {
  
  message<-data
  
  if(!is.null(id)) {
    message <- data %>%
      filter(who == id) %>%
      arrange(desc(date)) 
  }
  if(!is.null(dateStart)) {
      
   message <- data %>%
    filter(datex>=dateStart) %>%
    arrange(desc(date)) 
       }
  if(!is.null(dateEnd)) {
   
    message <- data %>%
      filter(datex <= dateEnd) %>%
      arrange(desc(date))
  }
 message
}

#
