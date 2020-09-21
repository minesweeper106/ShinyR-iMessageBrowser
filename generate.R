

generate <- function(data, id=NULL, ...) {
  
  parsed <- parser(data, id)
  index <- "<body>"
  
  for (i in 1:nrow(parsed)) {
    
    data <- datacalc(parsed$date[i])
    
    
    
    if (parsed$sent[i] == 0) 
    {
      htclass <-'<div class =\"container\">'
      p <- paste('<p class=\"left\"><i>From: '
                 ,parsed$who[i],
                 "</i></p><p>",
                 sep="")
      span <- "<span class=\"time-right\">"
      
    } else {
      htclass <-'<div class =\"container darker\">\n'  
      p <- '<p></p><p>'
      span <- "<span class=\"time-right\">"
    }
    
    
    index <- paste(index,
                   htclass,p,
                   parsed$text[i],
                   "</p>",
                   span,
                   data,
                   "</span></div>\n",
                   sep = "")
    
    
  }
  index
}
